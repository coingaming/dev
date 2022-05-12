Nothing:
Proxy txt@Text: #{txt}
Continue: Continue
Copy: copy
Iso3166v1: gb

HomeRBreadcrumb: Home
AuthRBreadcrumb: Login
SignoutRBreadcrumb: Signout
OpenChanRBreadcrumb: Outbound
SwapIntoLnCreateRBreadcrumb: Balanced
SwapIntoLnSelectRBreadcrumb swp@Uuid'SwapIntoLnTable: #{swp}
AboutRBreadcrumb: About

HomeRTitle: Welcome | LSP
OpenChanRTitle: Outbound | LSP
SwapIntoLnCreateRTitle: Balanced | LSP
SwapIntoLnSelectRTitle swp@Uuid'SwapIntoLnTable: #{swp} | Balanced | LSP
AboutRTitle: About | LSP

Home: Home
HomeBigHeader: BTC LSP
HomeSmallHeader: Lightning Network Service Provider

Outbound: Outbound
OpenOutboundChanToLsp: Outbound channel to LSP
OpenChanInstruction: To open a payment channel to the LSP, scan the QR code with your lightning wallet or manually copy the URI of the lightning node below.

Balanced: Balanced
SwapBalancedChanWithLsp: Balanced channel with LSP
SwapIntoLnUuid: Swap Uuid
SwapIntoLnUserId: User Pub Key
SwapIntoLnFundInvoice: Swap Invoice
SwapIntoLnFundInvHash: Swap Hash
SwapIntoLnFundAddress: Swap Address
SwapIntoLnFundProof: Proof of Swap
SwapIntoLnRefundAddress: Refund Address
SwapIntoLnChanCapUser: User Capacity
SwapIntoLnChanCapLsp: LSP Capacity
SwapIntoLnFeeLsp: LSP Swap Fee
SwapIntoLnFeeMiner: Channel Mining Fee
SwapIntoLnStatus: Swap Status
SwapIntoLnExpiresAt: Expires at
SwapIntoLnInsertedAt: Inserted at
SwapIntoLnUpdatedAt: Updated at
ChannelPrivacy: Channel Privacy

SwapIntoLnInfoShort: Step 1/5 - Swap Info
SwapIntoLnWaitingFundChainShort: Step 2/5 - Swap Funding
SwapIntoLnFundedShort: Step 3/5 - Peer Connection
SwapIntoLnWaitingChanShort: Step 4/5 - Channel Opening
SwapIntoLnWaitingFundLnShort: Step 4/5 - Lightning Funding
SwapIntoLnSucceededShort: Step 5/5 - Swap Succeeded
SwapIntoLnExpiredShort: Swap Expired!

SwapIntoLnInfoLong: To request a balanced channel with LSP, provide a lightning invoice with a zero requested amount and an expiration time of at least one week. LSP also needs emergency on-chain refund address.
SwapIntoLnWaitingFundChainLong: LSP is wating for the swap being funded. Please send bitcoins to the on-chain swap address:
SwapIntoLnFundedLong: The swap is successfully funded. LSP is waiting for your lightning node being connected as a peer. Use the URI below to establish connection from your lightning node:
SwapIntoLnWaitingChanLong: LSP initiated lightning channel. Waiting for the channel being opened.
SwapIntoLnWaitingFundLnLong: Lightning channel has been opened. Now LSP is settling swap lightning invoice.
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

About: About
AboutLsp: About LSP
AboutGeneralInfo: General Info
AboutGen0: LSP provides number of commercial infrastructural services for the lightning network nodes and users:
AboutGen1: Outbound channel to LSP
AboutGen2: gives the ability to
AboutGen3: send
AboutGen4: lightning network payments. In this case LSP works exactly like any other well-connected lightning node, providing payments routing for a regular lightning network fee without any other additional fees.
AboutGen5: Balanced channel with LSP
AboutGen6: gives ability to both
AboutGen7: send and receive
AboutGen8: lightning network payments. In this case LSP also provides inbound liquidity for the user, but takes additional one-time fee for it.
AboutSwap0: Creation of balanced channel with LSP is implemented through on-chain to lightning swap. On the first step user provides to LSP swap data:
AboutSwap1: Swap Invoice
AboutSwap2: - lightning invoice created by user's lightning node. This invoice is used to push swap liquidity to the user's side of the payment channel after channel is opened. LSP does not have any information how big the swap is gonna be, so provided invoice should be zero-amount only. LSP also does not have any information about user's node availability during the swap period, so expiration time of the invoice should be at least one week.
AboutSwap3: Refund Address
AboutSwap4: - emergency on-chain refund address, which is used by LSP for on-chain refunds in cases where bitcoins were send to the swap on-chain address, but swap has been already succeeded or expired.
AboutSwap5: Channel Privacy
AboutSwap6: - user can specify should new balanced channel with LSP be public or private.
AboutSwap7: On the next steps user needs to fund the swap on-chain, and receive balanced channel with incoming and outgoing liquidity on the lightning network:
AboutSwap8: User or somebody else sends bitcoins to on-chain swap address provided by LSP.
AboutSwap9: After the swap has been successfully funded on-chain, user's lightning node needs to connect to LSP lightning node as a peer. LSP will provide corresponding URI and QR code.
AboutSwap10: When user's lightning node is connected, LSP initiates channel opening with it.
AboutSwap11: After the channel is opened, LSP sends user's funds over lightning network using initial swap invoice. User's lightning node needs to be online to receive the payment.
AboutSwap12: After the successful swap, user's lightning node has a balanced payment channel with LSP's node and is able to both send and receive lightning payments. If something goes wrong and balanced channel is not able to be opened, user's bitcoins are refunded to provided emergency on-chain refund address.
