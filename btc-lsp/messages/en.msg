Nothing:
Proxy txt@Text: #{txt}
Failure txt@Text: Failure #{txt}
Yes: Yes
No: No
Active: Active
Continue: Continue
Update: Update
Updated: Updated
Copy: copy

HomeRBreadcrumb: Home
AuthRBreadcrumb: Login
SignoutRBreadcrumb: Signout
ProfileRBreadcrumb: Profile
CreateRBreadcrumb: New
OpenChanRBreadcrumb: Open Channel
SwapIntoLnCreateRBreadcrumb: Swap
SwapIntoLnSelectRBreadcrumb swp@Uuid'SwapIntoLnTable: #{swp}

HomeRTitle: Welcome | LSP
SignoutRTitle: Logout | LSP
ProfileRTitle usr@YesodUser: #{usr} | LSP
OpenChanRTitle: Open Channel | LSP
SwapIntoLnCreateRTitle: Swap | LSP
SwapIntoLnSelectRTitle swp@Uuid'SwapIntoLnTable: #{swp} | Swap | LSP

Home: Home
Profile: Profile
Login: Login
Logout: Logout
Iso639v1: en
Iso3166v1: gb

ProfilePageGreet usr@YesodUser: You are logged in as #{usr}

Name: Name
Password: Password

HomeBigHeader: BTC LSP
HomeSmallHeader: Lightning Network Service Provider

OpenChan: Open Channel
OpenChanInstruction: To open a payment channel to the LSP, scan the QR code with your lightning wallet or manually copy the URI of the lightning node below.

Swap: Swap
SwapIntoLnUuid: Swap Uuid
SwapIntoLnUserId: User Pub Key
SwapIntoLnFundInvoice: Swap Invoice
SwapIntoLnFundInvHash: Swap Hash
SwapIntoLnFundAddress: Swap Address
SwapIntoLnFundProof: Proof of Swap
SwapIntoLnRefundAddress: Refund Address
SwapIntoLnChanCapUser: User Capacity
SwapIntoLnChanCapLsp: Lsp Capacity
SwapIntoLnFeeLsp: Lsp Swap Fee
SwapIntoLnFeeMiner: Channel Mining Fee
SwapIntoLnStatus: Swap Status
SwapIntoLnExpiresAt: Expires at
SwapIntoLnInsertedAt: Inserted at
SwapIntoLnUpdatedAt: Updated at
ChannelPrivacy: Channel Privacy

SwapIntoLnWaitingFundChainShort: Step 1/4 - Swap Funding
SwapIntoLnFundedShort: Step 2/4 - Peer Connection
SwapIntoLnWaitingChanShort: Step 3/4 - Channel Opening
SwapIntoLnWaitingFundLnShort: Step 3/4 - Lightning Funding
SwapIntoLnSucceededShort: Step 4/4 - Swap Succeeded
SwapIntoLnExpiredShort: Swap Expired!

SwapIntoLnWaitingFundChainLong: Lsp is wating for the swap being funded. Please send bitcoins to the on-chain swap address:
SwapIntoLnFundedLong: The swap is successfully funded. Lsp is waiting for your lightning node being connected as a peer. Use the URI below to establish connection from your lightning node:
SwapIntoLnWaitingChanLong: Lsp initiated lightning channel. Waiting for the channel being opened.
SwapIntoLnWaitingFundLnLong: Lightning channel has been opened. Now Lsp is settling swap lightning invoice.
SwapIntoLnSucceededLong: Swap succeeded!
SwapIntoLnExpiredLong: Swap has been expired, and all the funds will be refunded to refund on-chain address.

Block: Block
TxId: TxId
Vout: Vout
Sat: Sat
Status: Status
SwapInfo: Swap Info
SwapUtxos: Swap UTXOs
SwapChans: Swap Channels

FailureDefault: Something went wrong. Please check the input data and try again.
FailureFundLnInvoiceHasNonZeroAmt: Provided swap invoice has non-zero amount requested. Only zero amount lightning invoices are accepted for the swaps.
FailureFundLnInvoiceExpiresTooSoon: Provided swap invoice expires too soon. Please set the expiration time to at least one week.
