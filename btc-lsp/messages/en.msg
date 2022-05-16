Nothing:
Proxy txt@Text: #{txt}
Continue: Continue
Copy: copy
Iso3166v1: gb
Satoshi: satoshi
SatoshiAmt msat@MSat: #{toMessage msat} satoshi

HomeRBreadcrumb: Home
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
AboutGen0: General Info
AboutGen1: LSP provides number of commercial infrastructural services for the lightning network nodes and users:
AboutGen2: Outbound channel to LSP
AboutGen3: gives the ability to
AboutGen4: send
AboutGen5: lightning network payments. In this case LSP works exactly like any other well-connected lightning node, providing payments routing for a regular lightning network fee without any other additional fees.
AboutGen6: Balanced channel with LSP
AboutGen7: gives ability to both
AboutGen8: send and receive
AboutGen9: lightning network payments. In this case LSP also provides inbound liquidity for the user, but takes additional one-time fee for it.
AboutMathGen0: Balanced Channel Math
AboutMathGen1: User is able to swap on-chain bitcoins into new balanced lightning channel with LSP. For example, if user sends
AboutMathGen2: X
AboutMathGen3: bitcoins to on-chain swap address, then after the swap user's lightning node will have
AboutMathGen4: X - LSP_FEE
AboutMathGen5: bitcoins of outgoing liquidity,
AboutMathGen6: X - LSP_FEE - COMMITMENT_FEE
AboutMathGen7: bitcoins of incoming liquidity and
AboutMathGen8: 2 * (X - LSP_FEE)
AboutMathGen9: bitcoins of total liquidity in the new lightning channel.
AboutMathMinMax0: The minimal acceptable amount
AboutMathMinMax1: X
AboutMathMinMax2: for the swap is
AboutMathMinMax3 minAmt@Money'Usr'OnChain'Fund: #{minAmt}
AboutMathMinMax4: satoshi and the maximum is
AboutMathMinMax5 maxAmt@Money'Usr'OnChain'Fund: #{maxAmt}
AboutMathMinMax6: satoshi.
AboutMathLspFee0: The value of the
AboutMathLspFee1: LSP_FEE
AboutMathLspFee2: depends on initial amount of
AboutMathLspFee3: X
AboutMathLspFee4: bitcoins which user sent to the on-chain swap address. LSP takes
AboutMathLspFee5 feeRate@FeeRate: #{feeRate}
AboutMathLspFee6: of
AboutMathLspFee7: X
AboutMathLspFee8: as a fee, but not less than
AboutMathLspFee9 minFee@Money'Lsp'OnChain'Gain: #{minFee}
AboutMathLspFee10: satoshi.
AboutMathCommFee0: The value of the
AboutMathCommFee1: COMMITMENT_FEE
AboutMathCommFee2: can vary, it depends on the state of the bitcoin network at a particular moment. It is a small percentage of the total capacity of the channel and is always processed by the LSP side, so it never affects user's lightning balance.
AboutSwap0: Balanced Channel Flow
AboutSwap1: Creation of balanced channel with LSP is implemented through on-chain to lightning swap. On the first step user provides to LSP swap data:
AboutSwap2: Swap Invoice
AboutSwap3: - lightning invoice created by user's lightning node. This invoice is used to push swap liquidity to the user's side of the payment channel after channel is opened. LSP does not have any information how big the swap is gonna be, so provided invoice should be zero-amount only. LSP also does not have any information about user's node availability during the swap period, so expiration time of the invoice should be at least one week.
AboutSwap4: Refund Address
AboutSwap5: - emergency on-chain refund address, which is used by LSP for on-chain refunds in cases where bitcoins were send to the swap on-chain address, but swap has been already succeeded or expired.
AboutSwap6: Channel Privacy
AboutSwap7: - user can specify should new balanced channel with LSP be public or private.
AboutSwap8: On the next steps user needs to fund the swap on-chain, and receive balanced channel with incoming and outgoing liquidity on the lightning network:
AboutSwap9: User or somebody else sends bitcoins to on-chain swap address provided by LSP.
AboutSwap10: After the swap has been successfully funded on-chain, user's lightning node needs to connect to LSP lightning node as a peer. LSP will provide corresponding URI and QR code.
AboutSwap11: When user's lightning node is connected, LSP initiates channel opening with it.
AboutSwap12: After the channel is opened, LSP sends user's funds over lightning network using initial swap invoice. User's lightning node needs to be online to receive the payment.
AboutSwap13: After the successful swap, user's lightning node has a balanced payment channel with LSP's node and is able to both send and receive lightning payments. If something goes wrong and balanced channel is not able to be opened, user's bitcoins are refunded to provided emergency on-chain refund address.
