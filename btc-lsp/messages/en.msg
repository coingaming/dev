#
# Untranslatable
#

Nothing:
Proxy txt@Text: #{txt}
UtcTime utc@UTCTime: #{formatAsLogTime utc} UTC

#
# Logo
#

L: L
S: S
P: P

#
# General
#

Iso3166v1: gb
Copy: copy
Continue: Continue
Amount: Amount
Satoshi msat@MSat: #{toMessage msat} satoshi
Status: Status
ExpiresAt: Expires at
InsertedAt: Inserted at
UpdatedAt: Updated at
ChannelPrivacy: Channel Privacy
Block: Block
TxId: Transaction Id
Vout: Output Index
InputFailure: Something went wrong. Please check the input data and try again.

#
# SwapStatus
#

SwapWaitingFundChain: Waiting for funding
SwapWaitingPeer: Waiting for the peer
SwapWaitingChan: Waiting for the channel
SwapSucceeded: Succeeded
SwapExpired: Expired

#
# SwapUtxoStatus
#

SwapUtxoUnspent: Unspent
SwapUtxoUnspentDust: Dust
SwapUtxoUnspentChanReserve: Reserved for the swap
SwapUtxoSpentChanSwapped: Spent for the swap
SwapUtxoSpentRefund: Refunded
SwapUtxoOrphan: Orphan

#
# LnChanStatus
#

LnChanStatusPendingOpen: Opening
LnChanStatusOpened: Opened
LnChanStatusActive: Active
LnChanStatusFullyResolved: Fully Resolved
LnChanStatusInactive: Inactive
LnChanStatusPendingClose: Closing
LnChanStatusClosed: Closed

#
# ChanPrivacy
#

ChanPrivate: Private
ChanPublic: Public

#
# Page title
#

HomeRTitle: Welcome | LSP
OpenChanRTitle: Outbound | LSP
SwapIntoLnCreateRTitle: Balanced | LSP
SwapIntoLnSelectRTitle swp@Uuid'SwapIntoLnTable: #{swp} | Balanced | LSP
AboutRTitle: About | LSP

#
# Page short link
#

HomeRLinkShort: Home
OpenChanRLinkShort: Outbound
SwapIntoLnCreateRLinkShort: Balanced
SwapIntoLnSelectRLinkShort swp@Uuid'SwapIntoLnTable: #{swp}
AboutRLinkShort: About

#
# Page long link
#

HomeRLinkLong: Home
OpenChanRLinkLong: Outbound channel to LSP
SwapIntoLnCreateRLinkLong: Balanced channel with LSP
SwapIntoLnSelectRLinkLong swp@Uuid'SwapIntoLnTable: #{swp}
AboutRLinkLong: About LSP

#
# HomeR
#

HomeBigHeader: BTC LSP
HomeSmallHeader: Lightning Network Service Provider

#
# OpenChanR
#

OpenChanInstruction: To open a payment channel to the LSP, scan the QR code with your lightning wallet or manually copy the URI of the lightning node below.

#
# SwapIntoLnCreateR
#

SwapIntoLnFailureRefundOnChainAddressIsNotValid: Provided on-chain refund address is not valid. LSP accepts only native segwit bech32 bitcoin addresses.
SwapIntoLnFailureRefundOnChainAddressIsNotSegwit: Provided on-chain refund address is not native segwit bech32 address. LSP accepts only native segwit bech32 bitcoin addresses.

#
# SwapIntoLnSelectR
#

SwapIntoLnHeaderInfo: Swap Info
SwapIntoLnHeaderUtxos: Swap Coins
SwapIntoLnHeaderChans: Swap Channels

SwapIntoLnTotalOnChainReceived: Total On-Chain Received
SwapIntoLnTotalOnChainReserved: Total On-Chain Reserved
SwapIntoLnTotalOnChainSwapped: Total On-Chain Swapped
SwapIntoLnTotalOnChainRefunded: Total On-Chain Refunded
SwapIntoLnTotalOnChainDust: Total On-Chain Dust
SwapIntoLnFeeLsp: LSP Service Fee
SwapIntoLnChanCapUser: User's Outgoing Capacity
SwapIntoLnChanCapLsp: User's Incoming Capacity *
SwapIntoLnChanCapTotal: Total Channel Capacity
SwapIntoLnFeeMiner: Channel Mining Fee
SwapIntoLnUuid: Swap Uuid
SwapIntoLnUserId: User Pub Key
SwapIntoLnFundInvoice: Swap Invoice
SwapIntoLnFundAddress: Swap Fund Address
SwapIntoLnRefundAddress: Swap Refund Address

SwapIntoLnInfoShort: Step 1/5 - Swap Info
SwapIntoLnWaitingFundChainShort: Step 2/5 - Swap Funding
SwapIntoLnFundedShort: Step 3/5 - Peer Connection
SwapIntoLnWaitingChanShort: Step 4/5 - Channel Opening
SwapIntoLnSucceededShort: Step 5/5 - Swap Succeeded
SwapIntoLnExpiredShort: Swap Expired!

SwapIntoLnInfoLong: To request a balanced channel with LSP, provide any lightning invoice created by your node. LSP also needs emergency on-chain refund address.
SwapIntoLnWaitingFundChainLong minAmt@Money'Usr'OnChain'Fund maxAmt@Money'Usr'OnChain'Fund: LSP is waiting for the swap to be funded. Please send between #{minAmt} and #{maxAmt} satoshi to the on-chain swap address:
SwapIntoLnFundedLong: The swap is successfully funded. LSP is waiting for your lightning node being connected as a peer. Use the URI below to establish connection from your lightning node:
SwapIntoLnWaitingChanLong: LSP initiated lightning channel. Waiting for the channel being opened.
SwapIntoLnSucceededLong: Swap succeeded!
SwapIntoLnExpiredLong: Swap has been expired, and all the funds will be refunded to refund on-chain address.

#
# Disclaimer
#

DisclaimerTos0: By continuing to use the LSP, you agree to the service
DisclaimerTos1: terms and conditions
DisclaimerCommitmentFee: * The actual value of the input capacity provided to the user by LSP is slightly less than the theoretical value, because LSP handles the commitment fee of the lightning channel, which can vary. The value of the commitment fee depends on the state of the bitcoin network at any given time.

#
# About
#

AboutGen0: General Info
AboutGen1: LSP provides a number of infrastructural services for lightning network nodes and users:
AboutGen2: Outbound channel to LSP
AboutGen3: provides the ability to
AboutGen4: send
AboutGen5: lightning network payments. In this case, LSP works exactly like any other highly available and well-connected lightning node, providing payment routing and charging a regular lightning network fee with no additional fees.
AboutGen6: Balanced channel with LSP
AboutGen7: provides the ability to
AboutGen8: send and receive
AboutGen9: lightning network payments. In this case, LSP also provides incoming liquidity for the user, but charges an additional one-time fee for it.
AboutGen10: The LSP software is open source. The source code can be found on github:
AboutGen11: https://github.com/coingaming/src
AboutGen12: Pull requests and other contributions are welcome!
AboutMathGen0: Balanced Channel Math
AboutMathGen1: The user is able to swap on-chain bitcoins into a balanced lightning channel with LSP. For example, the user sends
AboutMathGen2: X
AboutMathGen3: bitcoins to the on-chain swap address. After the swap, the user's lightning node will have
AboutMathGen4: X - LSP_FEE
AboutMathGen5: bitcoins of outgoing liquidity,
AboutMathGen6: X - LSP_FEE - COMMITMENT_FEE
AboutMathGen7: bitcoins of incoming liquidity and the new lightning channel will have
AboutMathGen8: 2 * (X - LSP_FEE)
AboutMathGen9: bitcoins of total liquidity.
AboutMathMinMax0: The minimum acceptable amount
AboutMathMinMax1: X
AboutMathMinMax2: for the swap is
AboutMathMinMax3 minAmt@Money'Usr'OnChain'Fund: #{minAmt}
AboutMathMinMax4: satoshi and the maximum is
AboutMathMinMax5 maxAmt@Money'Usr'OnChain'Fund: #{maxAmt}
AboutMathMinMax6: satoshi. All UTXOs less than
AboutMathMinMax7 dustLimit@MSat: #{dustLimit}
AboutMathMinMax8: satoshi are considered dust and will be ignored.
AboutMathLspFee0: The value of
AboutMathLspFee1: LSP_FEE
AboutMathLspFee2: depends on the initial amount of
AboutMathLspFee3: X
AboutMathLspFee4: bitcoins that the user sent to the on-chain swap address. LSP charges
AboutMathLspFee5 feeRate@FeeRate: #{feeRate}
AboutMathLspFee6: of
AboutMathLspFee7: X
AboutMathLspFee8: as a fee, but not less than
AboutMathLspFee9 minFee@Money'Lsp'OnChain'Gain: #{minFee}
AboutMathLspFee10: satoshi.
AboutMathCommFee0: The value of
AboutMathCommFee1: COMMITMENT_FEE
AboutMathCommFee2: can vary, it depends on the state of the bitcoin network at any given time. It is a small percentage of the total channel capacity and is always processed by the LSP, so it never affects user's outgoing lightning balance.
AboutExamples: Balanced Channel Examples
AboutExamplesUserOnChainFunding: User's On-Chain Swap Funds
AboutExamplesLspSwapFee: LSP Swap Fee
AboutExamplesUserOutgoingCap: User's Outgoing Capacity
AboutExamplesUserIncomingCap: User's Incoming Capacity *
AboutExamplesTotalChanCap: Total Channel Capacity
AboutSwap0: Balanced Channel Flow
AboutSwap1: The creation of a balanced channel with LSP is implemented through on-chain to lightning swap. On the first step, the user provides LSP swap data:
AboutSwap2: Swap Invoice
AboutSwap3: - lightning invoice created by user's lightning node. This invoice is used to identify the user's node.
AboutSwap4: Refund Address
AboutSwap5: - emergency on-chain refund address, which is used by LSP for on-chain refunds in cases where bitcoins were sent to the on-chain swap address, but the swap has already succeeded or expired.
AboutSwap6: Channel Privacy
AboutSwap7: - the user can specify whether the new lightning channel should be public or private.
AboutSwap8: On the next steps user needs to fund the on-chain swap address and receive a balanced channel with incoming and outgoing liquidity on the lightning network:
AboutSwap9: The user or somebody else sends bitcoins to the on-chain swap address provided by LSP.
AboutSwap10: After the swap has been successfully funded on-chain, the user's lightning node must connect to the LSP lightning node as a peer. LSP will provide the corresponding connection URI and QR code.
AboutSwap11: When the user's lightning node is connected, the LSP starts to open the channel with it.
AboutSwap12: Once the channel is opened, LSP sends the user's funds through the lightning network using the initial swap invoice. The user's lightning node must be online to receive the payment.
AboutSwap13: After the successful swap, the user's lightning node has a balanced payment channel with the LSP's node and can send and receive lightning payments. If something goes wrong and the balanced channel cannot be opened, the user's bitcoins are refunded to the emergency on-chain refund address provided by the user.
AboutDisclaimer0: Disclaimer
AboutDisclaimer1: The lightning network is an experimental technology. Using Lightning Network in general and LSP in particular can lead to the loss of funds. The LSP software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
