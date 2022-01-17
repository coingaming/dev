{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Model.User
  ( createVerify,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

--
-- TODO : create withVerifiedNonce because
-- actions with Bitcoin/LN should be atomic???
--
createVerify ::
  forall m sql.
  ( Storage m,
    sql ~ ReaderT Psql.SqlBackend m (Either Failure (Entity User))
  ) =>
  NodePubKey ->
  Nonce ->
  m (Either Failure (Entity User))
createVerify pub nonce = runSql $ do
  ct <-
    liftIO getCurrentTime
  let zeroRow =
        User
          { userNodePubKey = pub,
            userLatestNonce = Nonce 0,
            userInsertedAt = ct,
            userUpdatedAt = ct
          }
  let success :: sql =
        Right
          <$> Psql.upsertBy
            (UniqueUser pub)
            zeroRow
              { userLatestNonce = nonce
              }
            [ UserLatestNonce Psql.=. Psql.val nonce,
              UserUpdatedAt Psql.=. Psql.val ct
            ]
  rowId <-
    entityKey
      <$> Psql.upsertBy
        (UniqueUser pub)
        zeroRow
        --
        -- TODO : this update is redundant, but upsertBy is
        -- not working with mempty update argument -
        -- probably it's a bug in Esqueleto implementation,
        -- check it in latest version, and if not fixed -
        -- report issue or just fix it.
        --
        -- UPDATE : reported in github
        -- https://github.com/bitemyapp/esqueleto/issues/294
        --
        [ UserNodePubKey Psql.=. Psql.val pub
        ]
  existingRow <-
    entityVal
      <$> lockByRow rowId
  if existingRow == zeroRow
    then success
    else
      if userLatestNonce existingRow < nonce
        then success
        else pure $ Left FailureNonce
