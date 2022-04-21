{-# LANGUAGE PackageImports #-}

import "btc-lsp" BtcLsp.Yesod.Application (develMain)
import Prelude (IO)

main :: IO ()
main = develMain
