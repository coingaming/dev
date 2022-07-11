#
# Untranslatable
#

Nothing:
Proxy txt@Text: #{txt}
UtcTime utc@UTCTime: #{formatAsLogTime utc} UTC

#
# Logo
#

L: Л
S: С
P: П

#
# General
#

Iso3166v1: ru
Copy: копировать
Continue: Продолжить
Amount: Количество
Satoshi msat@MSat: #{toMessage msat} сатоши
Status: Статус
ExpiresAt: Истекает
InsertedAt: Создано
UpdatedAt: Обновлено
ChannelPrivacy: Приватность канала
Block: Блок
TxId: Транзакция
Vout: Индекс выхода
InputFailure: Произошла ошибка. Пожалуйста проверьте правильность введённых данных и попытайтесь снова.

#
# SwapStatus
#

SwapWaitingFundChain: Ожидание платежа
SwapWaitingPeer: Ожидание соединения
SwapWaitingChan: Ожидание канала
SwapWaitingFundLn: Оплата инвойса
SwapSucceeded: Успешно завершено
SwapExpired: Срок истёк

#
# SwapUtxoStatus
#

SwapUtxoUnspent: Не потрачено
SwapUtxoUnspentDust: Пыль
SwapUtxoUnspentChanReserve: Зарезервировано
SwapUtxoSpentChan: Потрачено для канала
SwapUtxoSpentChanSwapped: Потрачено для свопа
SwapUtxoSpentRefund: Возвращено
SwapUtxoOrphan: Реорганизовано

#
# LnChanStatus
#

LnChanStatusPendingOpen: Открывается
LnChanStatusOpened: Открыт
LnChanStatusActive: Активен
LnChanStatusFullyResolved: Полностью разрешён
LnChanStatusInactive: Не активен
LnChanStatusPendingClose: Закрывается
LnChanStatusClosed: Закрыт

#
# ChanPrivacy
#

ChanPrivate: Приватный
ChanPublic: Публичный

#
# Page title
#

HomeRTitle: Добро пожаловать | ЛСП
OpenChanRTitle: Исходящий | ЛСП
SwapIntoLnCreateRTitle: Балансный | ЛСП
SwapIntoLnSelectRTitle swp@Uuid'SwapIntoLnTable: #{swp} | Балансный | ЛСП
AboutRTitle: Информация | ЛСП

#
# Page short link
#

HomeRLinkShort: Главная
OpenChanRLinkShort: Исходящий
SwapIntoLnCreateRLinkShort: Балансный
SwapIntoLnSelectRLinkShort swp@Uuid'SwapIntoLnTable: #{swp}
AboutRLinkShort: Информация

#
# Page long link
#

HomeRLinkLong: Главная
OpenChanRLinkLong: Исходящий канал к ЛСП
SwapIntoLnCreateRLinkLong: Балансный канал с ЛСП
SwapIntoLnSelectRLinkLong swp@Uuid'SwapIntoLnTable: #{swp}
AboutRLinkLong: Информация о ЛСП

#
# HomeR
#

HomeBigHeader: Биткоин ЛСП
HomeSmallHeader: Лайтнинг Сервис Провайдер

#
# OpenChanR
#

OpenChanInstruction: Чтобы открыть исходящий канал к ЛСП, отсканируйте куар код своим лайтнинг кошельком, или вручную скопируйте адрес лайтнинг ноды находящийся ниже.

#
# SwapIntoLnCreateR
#

SwapIntoLnFailureFundLnInvoiceHasNonZeroAmt: Предоставленный инвойс запрашивает не нулевое количество сатоши. Только нулевые инвойсы принимаются для свопов.
SwapIntoLnFailureFundLnInvoiceExpiresTooSoon: Предоставленный инвойс истекает слишком рано. Пожалуйста установите срок оплаты как минимум в одну неделю.
SwapIntoLnFailureRefundOnChainAddressIsNotValid: Предоставленный он-чейн адрес для возврата не валиден. ЛСП принимает только нативные segwit bech32 адреса.
SwapIntoLnFailureRefundOnChainAddressIsNotSegwit: Предоставленный он-чейн адрес для возврата не является нативным segwit bech32 адресом. ЛСП принимает только нативные segwit bech32 адреса.

#
# SwapIntoLnSelectR
#

SwapIntoLnHeaderInfo: Информация свопа
SwapIntoLnHeaderUtxos: Монеты свопа
SwapIntoLnHeaderChans: Каналы свопа

SwapIntoLnTotalOnChainReceived: Итого получено он-чейн
SwapIntoLnTotalOnChainReserved: Итого зарезервировано он-чейн
SwapIntoLnTotalOnChainSwapped: Итого обменяно он-чейн
SwapIntoLnTotalOnChainRefunded: Итого возвращено он-чейн
SwapIntoLnTotalOnChainDust: Итого пыль он-чейн
SwapIntoLnFeeLsp: Комиссия ЛСП
SwapIntoLnChanCapUser: Исходящая ликвидность пользователя
SwapIntoLnChanCapLsp: Входящая ликвидность пользователя  *
SwapIntoLnChanCapTotal: Общая ликвидность канала
SwapIntoLnFeeMiner: Комиссия майнеров
SwapIntoLnUuid: Идентификатор свопа
SwapIntoLnUserId: Публичный ключ пользователя
SwapIntoLnFundInvoice: Инвойс свопа
SwapIntoLnFundInvHash: Хеш инвойса свопа
SwapIntoLnFundAddress: Адрес финансирования свопа
SwapIntoLnFundProof: Прообраз инвойса свопа
SwapIntoLnRefundAddress: Адрес возврата свопа

SwapIntoLnInfoShort: Шаг 1/5 - Информация свопа
SwapIntoLnWaitingFundChainShort: Шаг 2/5 - Финансирование свопа
SwapIntoLnFundedShort: Шаг 3/5 - Соединение с нодой
SwapIntoLnWaitingChanShort: Шаг 4/5 - Открытие канала
SwapIntoLnWaitingFundLnShort: Шаг 4/5 - Финансирование канала
SwapIntoLnSucceededShort: Шаг 5/5 - Своп успешно выполнен
SwapIntoLnExpiredShort: Срок свопа истёк!

SwapIntoLnInfoLong: Для того чтобы запросить балансный канал с ЛСП, предоставьте лайтнинг инвойс с нулевым количеством сатоши и сроком оплаты в одну неделю или более. ЛСП также требует наличие он-чейн адреса для экстренного возврата.
SwapIntoLnWaitingFundChainLong minAmt@Money'Usr'OnChain'Fund maxAmt@Money'Usr'OnChain'Fund: ЛСП ожидает оплаты свопа. Пожалуйста отправьте от #{minAmt} до #{maxAmt} сатоши на он-чейн адрес:
SwapIntoLnFundedLong: Своп успешно оплачен. ЛСП ожидает входящего соединения от вашей лайтнинг ноды. Используйте предоставленный ниже адрес для соединения вашей лайтнинг ноды с ЛСП:
SwapIntoLnWaitingChanLong: ЛСП открывает канал. Подождите пока канал не откроется.
SwapIntoLnWaitingFundLnLong: Лайтнинг канал открыт. ЛСП оплачивает своп инвойс.
SwapIntoLnSucceededLong: Своп успешно выполнен!
SwapIntoLnExpiredLong: Срок свопа истёк и все предоставленные средства будут отправлены на он-чейн адрес вощврата.

#
# Disclaimer
#

DisclaimerTos0: Продолжая использовать ЛСП, вы соглашаетесь с
DisclaimerTos1: условиями сервиса
DisclaimerCommitmentFee: * Реальное значение входящей ликвидности предоставленной пользователю ЛСП всегда немного меньше теоретического значения, так как ЛСП оплачивает коммитмент комиссию использования лайтнинг канала. Значение этой комиссии может варьироваться и зависит от состояния биткоин сети в каждый отдельно взятый момент времени.

#
# About
#

AboutGen0: Общая информация
AboutGen1: ЛСП предоставляет инфраструктурные сервисы для пользователей лайтнинг сети:
AboutGen2: Исходящий канал к ЛСП
AboutGen3: даёт возможность
AboutGen4: отправлять
AboutGen5: лайтнинг платежи. В этом случае ЛСП работает точно так же как и любая другая лайтнинг нода с хорошей связностью, предоставляя маршрутизацию для лайтнинг платежей без дополнительной комиссии.
AboutGen6: Балансный канал с ЛСП
AboutGen7: даёт возможность
AboutGen8: отправлять и принимать
AboutGen9: лайтнинг платежи. В этом случае ЛСП также предоставляет входящую ликвидность для пользователя, но берёт дополнительную единовременную комиссию за предоставленную ликвидность.
AboutGen10: ЛСП это ПО с открытым исходным кодом. Исходный код размещён на сайте github:
AboutGen11: https://github.com/coingaming/src
AboutGen12: Пулл реквесты и другие вклады приветствуются!
AboutMathGen0: Математика балансного канала
AboutMathGen1: Пользователь может обменять он-чейн биткоины на балансный канал с ЛСП. Например, пользователь отправляет
AboutMathGen2: X
AboutMathGen3: биткоинов на обменный он-чейн адрес. После обмена, лайтнинг нода пользователя будет иметь
AboutMathGen4: X - LSP_FEE
AboutMathGen5: биткоинов исходящей ликвидности,
AboutMathGen6: X - LSP_FEE - COMMITMENT_FEE
AboutMathGen7: биткоинов входящей ликвидности и новый лайтнинг канал будет иметь
AboutMathGen8: 2 * (X - LSP_FEE)
AboutMathGen9: биткоинов общей ликвидности.
AboutMathMinMax0: Минимальное допустимое количество
AboutMathMinMax1: X
AboutMathMinMax2: для обмена равно
AboutMathMinMax3 minAmt@Money'Usr'OnChain'Fund: #{minAmt}
AboutMathMinMax4: сатоши, и максимальное количество равно
AboutMathMinMax5 maxAmt@Money'Usr'OnChain'Fund: #{maxAmt}
AboutMathMinMax6: сатоши. Все монеты меньше чем
AboutMathMinMax7 dustLimit@MSat: #{dustLimit}
AboutMathMinMax8: сатоши считаются пылью и будут игнорироваться.
AboutMathLspFee0: Значение
AboutMathLspFee1: LSP_FEE
AboutMathLspFee2: зависит от изначального количества
AboutMathLspFee3: X
AboutMathLspFee4: биткоинов которые пользователь отправил на он-чейн адрес обмена. ЛСП берёт
AboutMathLspFee5 feeRate@FeeRate: #{feeRate}
AboutMathLspFee6: от
AboutMathLspFee7: X
AboutMathLspFee8: в качестве комиссии, но комиссия не может быть менее
AboutMathLspFee9 minFee@Money'Lsp'OnChain'Gain: #{minFee}
AboutMathLspFee10: сатоши.
AboutMathCommFee0: Значение
AboutMathCommFee1: COMMITMENT_FEE
AboutMathCommFee2: может варьироваться, оно зависит от состояния биткоин сети в отдельно взятый момент времени. Оно представляет собой небольшой процент от общей ликвидности канала и всегда оплачивается ЛСП, следовательно оно никогда не затрагивает значение исходящей ликвидности пользователя.
AboutExamples: Примеры балансных каналов
AboutExamplesUserOnChainFunding: Он-чейн платёж пользователя
AboutExamplesLspSwapFee: Обменная комиссия ЛСП
AboutExamplesUserOutgoingCap: Исходящая ликвидность пользователя
AboutExamplesUserIncomingCap: Входящая ликвидность пользователя *
AboutExamplesTotalChanCap: Общая ликвидность канала
AboutSwap0: Открытие балансного канала
AboutSwap1: Открытие балансного канала с ЛСП осуществояется через обмен он-чейн биткоин на лайтнинг биткоины. На первом этапе пользователь предоставляет для ЛСП данные для обмена:
AboutSwap2: Обменный инвойс
AboutSwap3: - лайтнинг инвойс созданный лайтнинг нодой пользователя. Этот инвойс используется для того чтобы перенести ликвидность на сторону пользователя после того как лайтнинг канал откроется.
AboutSwap4: Адрес возврата
AboutSwap5: - ончейн для экстренного возврата, который используется ЛСП для ончейн возврата в случаях когда биткоины были отправлены на ончейн адрес обмена, но процедура обмен уже была завершена или её срок истёк.
AboutSwap6: Приватность канала
AboutSwap7: - пользователь может указать каким должен быть новый лайтнинг канал - публичным или приватным.
AboutSwap8: Далее пользователь должен отправить биткоины на ончейн адрес обмена и получить входящий балансный канал в лайтнинг сети:
AboutSwap9: Пользователь или кто-либо ещё отправляет биткоины на ончейн адрес обмена предоставленный ЛСП.
AboutSwap10: После того как процедура обмена была успешно оплачена ончейн, лайтнинг нода пользователя должна подключиться к лайтнинг ноде ЛСП. Для этого ЛСП предоставит соответствующий адрес и куар код.
AboutSwap11: Когда лайтнинг нода пользователя подключится, ЛСП начнёт процедуру открытия лайтнинг канала.
AboutSwap12: Когда лайтнинг канал откроется, ЛСП отправлит биткоины пользователю через этот канал используя предоставленный изначально обменный инвойс. Лайтнинг нода пользователя должна быть в сети чтобы получить этот платёж.
AboutSwap13: После успешного обмена, лайтнинг нода пользователя имеет балансный канал с ЛСП и может как отправлять так и принимать лайтнинг платежи. Если что-то пошло не так и лайтнинг канал не может быть открыт, биткоины пользователя отправляются на предоставленный им ончейн адрес возврата.
AboutDisclaimer0: Отказ от ответственности
AboutDisclaimer1: Лайтнинг сеть - это экспериментальная технология. Использование лайтнинг сети в целом и ЛСП в частности может привести к потере средств. Программное обеспечение ЛСП предоставляется "как есть", без каких-либо гарантий, явно выраженных или подразумеваемых, включая гарантии товарной пригодности, соответствия по его конкретному назначению и отсутствия нарушений, но не ограничиваясь ими. Ни в каком случае авторы или правообладатели не несут ответственности по каким-либо искам, за ущерб или по иным требованиям, в том числе, при действии контракта, деликте или иной ситуации, возникшим из-за использования программного обеспечения или иных действий с программным обеспечением.
