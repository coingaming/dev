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

SwapWaitingFundChain: Ожидание оплаты
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
SwapUtxoUnspentChanReserve: Зарезервировано для обмена
SwapUtxoSpentChan: Потрачено на канал
SwapUtxoSpentChanSwapped: Потрачено на обмен
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

OpenChanInstruction: Чтобы открыть исходящий канал к ЛСП, отсканируйте куар код своим лайтнинг кошельком, или вручную скопируйте адрес лайтнинг узла приведённый ниже.

#
# SwapIntoLnCreateR
#

SwapIntoLnFailureFundLnInvoiceHasNonZeroAmt: Предоставленный инвойс запрашивает не нулевое количество сатоши. Только нулевые инвойсы принимаются для обмена.
SwapIntoLnFailureFundLnInvoiceExpiresTooSoon: Предоставленный инвойс истекает слишком рано. Пожалуйста установите срок оплаты как минимум в одну неделю.
SwapIntoLnFailureRefundOnChainAddressIsNotValid: Предоставленный ончейн адрес для возврата не валиден. ЛСП принимает только нативные segwit bech32 адреса.
SwapIntoLnFailureRefundOnChainAddressIsNotSegwit: Предоставленный ончейн адрес для возврата не является нативным segwit bech32 адресом. ЛСП принимает только нативные segwit bech32 адреса.

#
# SwapIntoLnSelectR
#

SwapIntoLnHeaderInfo: Информация обмена
SwapIntoLnHeaderUtxos: Монеты обмена
SwapIntoLnHeaderChans: Каналы обмена

SwapIntoLnTotalOnChainReceived: Итого получено ончейн
SwapIntoLnTotalOnChainReserved: Итого зарезервировано ончейн
SwapIntoLnTotalOnChainSwapped: Итого обменяно ончейн
SwapIntoLnTotalOnChainRefunded: Итого возвращено ончейн
SwapIntoLnTotalOnChainDust: Итого пыль
SwapIntoLnFeeLsp: Комиссия ЛСП
SwapIntoLnChanCapUser: Исходящая ликвидность пользователя
SwapIntoLnChanCapLsp: Входящая ликвидность пользователя  *
SwapIntoLnChanCapTotal: Общая ликвидность канала
SwapIntoLnFeeMiner: Комиссия майнеров
SwapIntoLnUuid: Идентификатор обмена
SwapIntoLnUserId: Публичный ключ пользователя
SwapIntoLnFundInvoice: Инвойс обмена
SwapIntoLnFundInvHash: Хеш инвойса обмена
SwapIntoLnFundAddress: Адрес оплаты обмена
SwapIntoLnFundProof: Прообраз инвойса обмена
SwapIntoLnRefundAddress: Адрес возврата обмена

SwapIntoLnInfoShort: Шаг 1/5 - Информация обмена
SwapIntoLnWaitingFundChainShort: Шаг 2/5 - Оплата обмена
SwapIntoLnFundedShort: Шаг 3/5 - Соединение с узлом
SwapIntoLnWaitingChanShort: Шаг 4/5 - Открытие канала
SwapIntoLnWaitingFundLnShort: Шаг 4/5 - Оплата канала
SwapIntoLnSucceededShort: Шаг 5/5 - Обмен успешно выполнен
SwapIntoLnExpiredShort: Срок обмена истёк!

SwapIntoLnInfoLong: Для того чтобы запросить балансный канал с ЛСП, предоставьте любой лайтнинг инвойс созданный вашим лайтнинг узлом. ЛСП также требует наличие ончейн адреса для экстренного возврата.
SwapIntoLnWaitingFundChainLong minAmt@Money'Usr'OnChain'Fund maxAmt@Money'Usr'OnChain'Fund: ЛСП ожидает оплаты обмена. Пожалуйста отправьте от #{minAmt} до #{maxAmt} сатоши на ончейн адрес:
SwapIntoLnFundedLong: Обмен успешно оплачен. ЛСП ожидает входящего соединения от вашего лайтнинг узла. Используйте предоставленный ниже адрес для соединения вашего лайтнинг узла с ЛСП:
SwapIntoLnWaitingChanLong: ЛСП открывает канал. Подождите пока канал откроется.
SwapIntoLnWaitingFundLnLong: Лайтнинг канал открыт. ЛСП оплачивает инвойс обмена.
SwapIntoLnSucceededLong: Обмен успешно выполнен!
SwapIntoLnExpiredLong: Срок обмена истёк и все предоставленные средства будут отправлены на ончейн адрес возврата.

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
AboutGen5: лайтнинг платежи. В этом случае ЛСП работает точно так же как и любой другой лайтнинг узел с хорошей связностью, предоставляя маршрутизацию для лайтнинг платежей без дополнительной комиссии.
AboutGen6: Балансный канал с ЛСП
AboutGen7: даёт возможность
AboutGen8: отправлять и принимать
AboutGen9: лайтнинг платежи. В этом случае ЛСП также предоставляет входящую ликвидность для пользователя, но берёт дополнительную единовременную комиссию за предоставленную ликвидность.
AboutGen10: ЛСП это ПО с открытым исходным кодом. Исходный код размещён на сайте github:
AboutGen11: https://github.com/coingaming/src
AboutGen12: Пулл реквесты и другая помощь приветствуются!
AboutMathGen0: Математика балансного канала
AboutMathGen1: Пользователь может обменять ончейн биткоины на балансный канал с ЛСП. Например, пользователь отправляет
AboutMathGen2: X
AboutMathGen3: биткоинов на обменный ончейн адрес. После обмена, лайтнинг узел пользователя будет иметь
AboutMathGen4: X - КОМИССИЯ_ЛСП
AboutMathGen5: биткоинов исходящей ликвидности,
AboutMathGen6: X - КОМИССИЯ_ЛСП - КОММИТМЕНТ_КОМИССИЯ
AboutMathGen7: биткоинов входящей ликвидности и новый лайтнинг канал будет иметь
AboutMathGen8: 2 * (X - КОМИССИЯ_ЛСП)
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
AboutMathLspFee1: КОМИССИЯ_ЛСП
AboutMathLspFee2: зависит от изначального количества
AboutMathLspFee3: X
AboutMathLspFee4: биткоинов которые пользователь отправил на ончейн адрес обмена. ЛСП берёт
AboutMathLspFee5 feeRate@FeeRate: #{feeRate}
AboutMathLspFee6: от
AboutMathLspFee7: X
AboutMathLspFee8: в качестве комиссии, но комиссия не может быть менее
AboutMathLspFee9 minFee@Money'Lsp'OnChain'Gain: #{minFee}
AboutMathLspFee10: сатоши.
AboutMathCommFee0: Значение
AboutMathCommFee1: КОММИТМЕНТ_КОМИССИЯ
AboutMathCommFee2: может варьироваться, оно зависит от состояния биткоин сети в отдельно взятый момент времени. Оно представляет собой небольшой процент от общей ликвидности канала и всегда оплачивается ЛСП, следовательно оно никогда не затрагивает значение исходящей ликвидности пользователя.
AboutExamples: Примеры балансных каналов
AboutExamplesUserOnChainFunding: Ончейн платёж пользователя
AboutExamplesLspSwapFee: Обменная комиссия ЛСП
AboutExamplesUserOutgoingCap: Исходящая ликвидность пользователя
AboutExamplesUserIncomingCap: Входящая ликвидность пользователя *
AboutExamplesTotalChanCap: Общая ликвидность канала
AboutSwap0: Открытие балансного канала
AboutSwap1: Открытие балансного канала с ЛСП осуществояется через обмен ончейн биткоинов на лайтнинг биткоины. На первом этапе пользователь предоставляет для ЛСП данные для обмена:
AboutSwap2: Обменный инвойс
AboutSwap3: - лайтнинг инвойс созданный лайтнинг узлом пользователя. Этот инвойс используется для того чтобы перенести ликвидность на сторону пользователя после того как лайтнинг канал откроется.
AboutSwap4: Адрес возврата
AboutSwap5: - ончейн адрес для экстренного возврата, который используется ЛСП для ончейн возврата в случаях когда биткоины были отправлены на ончейн адрес обмена, но процедура обмена уже была завершена или её срок истёк.
AboutSwap6: Приватность канала
AboutSwap7: - пользователь может указать каким должен быть новый лайтнинг канал - публичным или приватным.
AboutSwap8: Далее пользователь должен отправить биткоины на ончейн адрес обмена и получить входящий балансный канал в лайтнинг сети:
AboutSwap9: Пользователь или кто-либо ещё отправляет биткоины на ончейн адрес обмена предоставленный ЛСП.
AboutSwap10: После того как процедура обмена была успешно оплачена ончейн, лайтнинг узел пользователя должен подключиться к лайтнинг узлу ЛСП. Для этого ЛСП предоставит соответствующий адрес и куар код.
AboutSwap11: Когда лайтнинг узел пользователя подключится, ЛСП начнёт процедуру открытия лайтнинг канала.
AboutSwap12: Когда лайтнинг канал откроется, ЛСП отправит биткоины пользователю через этот канал используя предоставленный обменный инвойс. Лайтнинг узел пользователя должен быть в сети чтобы получить этот платёж.
AboutSwap13: После успешного обмена, лайтнинг узел пользователя имеет балансный канал с ЛСП и может как отправлять так и принимать лайтнинг платежи. Если что-то пошло не так и лайтнинг канал не может быть открыт, биткоины пользователя отправляются на предоставленный им ончейн адрес возврата.
AboutDisclaimer0: Отказ от ответственности
AboutDisclaimer1: Лайтнинг сеть - это экспериментальная технология. Использование лайтнинг сети в целом и ЛСП в частности может привести к потере средств. Программное обеспечение ЛСП предоставляется "как есть", без каких-либо гарантий, явно выраженных или подразумеваемых, включая гарантии товарной пригодности, соответствия по его конкретному назначению и отсутствия нарушений, но не ограничиваясь ими. Ни в каком случае авторы или правообладатели не несут ответственности по каким-либо искам, за ущерб или по иным требованиям, в том числе, при действии контракта, деликте или иной ситуации, возникшим из-за использования программного обеспечения или иных действий с программным обеспечением.
