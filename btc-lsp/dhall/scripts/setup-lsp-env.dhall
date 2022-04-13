let G = ../Global.dhall

let Lsp = ../Service/Lsp.dhall

in  Lsp.mkSetupEnv G.Owner.Lsp
