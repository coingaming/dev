{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.Profile where

import BtcLsp.Yesod.Import

getProfileR :: Handler Html
getProfileR = do
  (_, user) <- requireAuthPair
  defaultLayout $ do
    setTitle . toHtml $ yesodUserIdent user <> "'s User page"
    $(widgetFile "profile")
