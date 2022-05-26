{-# LANGUAGE TypeApplications #-}

module BtcLsp.Storage.Model.User
  ( createVerifySql,
  )
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import hiding (Storage (..))
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Util as Util

--
-- NOTE : We will not create withVerifiedNonce
-- for now to reduce complexity overall.
-- Plus this combinator enables all kinds of
-- possibilities for deadlocks.
--
createVerifySql ::
  ( MonadIO m
  ) =>
  NodePubKey ->
  Nonce ->
  ReaderT Psql.SqlBackend m (Either Failure (Entity User))
createVerifySql pub nonce = do
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
  existingRow <- Util.lockByRow rowId
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
