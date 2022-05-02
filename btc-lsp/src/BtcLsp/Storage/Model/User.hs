{-# LANGUAGE TypeApplications #-}

module BtcLsp.Storage.Model.User
  ( createVerify,
  )
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

--
-- NOTE : We will not create withVerifiedNonce
-- for now to reduce complexity overall.
-- Plus this combinator enables all kinds of
-- possibilities for deadlocks.
--
createVerify ::
  ( Storage m
  ) =>
  NodePubKey ->
  Nonce ->
  m (Either Failure (Entity User))
createVerify pub nonce = runSql $ do
  ct <- getCurrentTime
  let zeroRow =
        User
          { userNodePubKey = pub,
            userLatestNonce = from @Word64 0,
            userInsertedAt = ct,
            userUpdatedAt = ct
          }
  rowId <-
    entityKey
      <$> Psql.upsertBy
        (UniqueUser pub)
        zeroRow
        [ UserUpdatedAt Psql.=. Psql.val ct
        ]
  existingRow <- lockByRow rowId
  if (existingRow == zeroRow)
    || (userLatestNonce existingRow < nonce)
    then
      Right
        <$> Psql.upsertBy
          (UniqueUser pub)
          zeroRow
            { userLatestNonce = nonce
            }
          [ UserLatestNonce Psql.=. Psql.val nonce,
            UserUpdatedAt Psql.=. Psql.val ct
          ]
    else
      pure $
        Left FailureNonce
