const String googleMapApiKey = 'AIzaSyCA3pEgx8Rx2Jh6BLSIz6OyDla_gF5owJY';// new active
///my api
const String baseUrl = 'https://api.ma7loula.com/api/v1/';

const String loginEndPoint = 'bt-vendor/login';
const String registerRequirementsDocEndPoint =
    'bt-vendor/register-requirements';
const String registerEndPoint = 'bt-vendor/register';
const String otpEndPoint = 'auth/send-otp';
const String verifyOtpEndPoint = 'auth/verify-otp';
const String getProfileEndPoint = 'bt-vendor/user-profile';
const String resetPasswordEndPoint = 'auth/reset-password';
const String updatePasswordEndPoint = 'auth/update-password';
const String updateProfileEndPoint = 'auth/update-profile';
const String updateAddressEndPoint = 'bt-vendor/update_address';
const String updatePhoneEndPoint = 'auth/update-phone';
const String startUpSlidesEndPoint = 'bt-vendor/start';
const String carsEndPoint = 'client/car/list';
const String carByIdEndPoint = 'car/getById';
const String slidersEndPoint = 'bt-vendor/sliders';
const String carPartsEndPoint = 'client/car-parts/categories';
const String carsModelEndPoint = 'car/models';
const String carsTypeEndPoint = 'car/brands';
const String yearsCarsEndPoint = 'car/years';
const String allCarsEndPoint = 'car/list';
const String addCarEndPoint = 'client/car/add';
const String deleteCarEndPoint = 'client/car/delete';
const String myOrdersBatteriesEndPoint = 'bt-vendor/order/';
const String myOrdersTiresEndPoint = 'client/tires/list-orders';
const String statesEndPoint = 'address/states';
const String citiesEndPoint = 'address/cities';
const String addAddressEndPoint = 'client/address/create';
const String addressesEndPoint = 'client/address/list';
const String deleteAddressEndPoint = 'client/address/delete';
const String createCarPartsOrderEndPoint = 'client/car-parts/create-order';
const String setAddressDefaultEndPoint = 'client/address/set-default';
const String setCarDefaultEndPoint = 'client/car/set-default';
const String volatagesEndPoint = 'client/batteries/volatages';
const String tiresBrandsEndPoint = 'bt-vendor/product/list-brands/tires';
const String tiresTypesEndPoint = 'client/tires/types';
const String tiresSizesEndPoint = 'client/tires/sizes';
const String brandsEndPoint = 'bt-vendor/product/list-brands/batteries';
const String cancelBatteryOrderEndPoint =
    'client/batteries/update-order-status';
const String cancelCarPartsOrderEndPoint =
    'client/car-parts/update-order-status';
const String cancelTiresOrderEndPoint = 'client/tires/update-order-status';
const String rateBatteryOrderEndPoint = 'client/batteries/rate-order';
const String rateCarPartsOrderEndPoint = 'client/car-parts/rate-order';
const String rateTiresOrderEndPoint = 'client/tires/rate-order';
//=============================================================
//=============================================================
// =============================================================
// =============================================================
//=============================================================
//=============================================================
const String productsEndPoint = 'bt-vendor/product/list/batteries/';
const String myOrdersEndPoint = 'bt-vendor/order/:status';
const String batteriesProductsEndPoint =
    'bt-vendor/product/list/batteries/:status';
const String tiresProductsEndPoint = 'bt-vendor/product/list/tires/';
const String batteriesProductsByIdEndPoint = 'bt-vendor/product';
const String addTireEndPoint = 'bt-vendor/product/add-tire';
const String addBatteryEndPoint = 'bt-vendor/product/add-battery';
const String detailsCarPartsOrderEndPoint = 'bt-vendor/order/details';
//=============================================================
//=============================================================
//=============================================================
//=============================================================
const String detailsBatteryOrderEndPoint = 'client/batteries/order-details';
const String detailsTiresOrderEndPoint = 'client/tires/order-details';
const String createBatteriesOrderEndPoint = 'client/batteries/create-order';
const String createTiresOrderEndPoint = 'client/tires/create-order';
const String tiresAvaTimeEndPoint = 'client/tires/available-slots';
const String batteriesAvaTimeEndPoint = 'client/batteries/available-slots';
const String carPartsAvaTimeEndPoint = 'client/car-parts/available-slots';
const String aboutAppEndPoint = 'client/about-app';
const String faqEndPoint = 'client/faq';
const String privacyEndPoint = 'client/privacy-policy';
const String termsEndPoint = 'client/terms-and-conditions';

//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
// =============================================================
// =============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
// =============================================================
// =============================================================
//=============================================================
//=============================================================

const String loginCarPartsEndPoint = 'car-parts-vendor/login';
const String registerRequirementsDocCarPartsEndPoint =
    'car-parts-vendor/register-requirements';
const String registerCarPartsEndPoint = 'car-parts-vendor/register';
const String getProfileCarPartsEndPoint = 'car-parts-vendor/user-profile';
const String startUpSlidesCarPartsEndPoint = 'car-parts-vendor/start';
const String slidersCarPartsEndPoint = 'car-parts-vendor/sliders';
const String myOrdersBatteriesCarPartsEndPoint = 'car-parts-vendor/order/';
const String tiresBrandsCarPartsEndPoint =
    'car-parts-vendor/product/list-brands/tires';
const String brandsCarPartsEndPoint =
    'car-parts-vendor/product/list-brands/products';
const String productsCarPartsEndPoint = 'car-parts-vendor/product/list/';
const String myOrdersCarPartsEndPoint = 'car-parts-vendor/order/:status';
const String batteriesProductsCarPartsEndPoint =
    'car-parts-vendor/product/list/batteries/:status';
const String tiresProductsCarPartsEndPoint =
    'car-parts-vendor/product/list/tires/';
const String batteriesProductsByIdCarPartsEndPoint = 'car-parts-vendor/product';
const String addTireCarPartsEndPoint = 'car-parts-vendor/product/add-tire';
const String addBatteryCarPartsEndPoint =
    'car-parts-vendor/product/add-product';
const String detailsCarPartsOrderCarPartsEndPoint =
    'car-parts-vendor/order/details';

//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
// =============================================================
// =============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
// =============================================================
// =============================================================
//=============================================================
//=============================================================

const String updateLocationEmergencyEndPoint = 'emergency/update-location';
const String getEmergencyOffersEndPoint = 'emergency/order/check';
const String sentOfferEmergencyEndPoint = 'emergency/order/send-offer';
const String updateEmergencyOrderStatusEndPoint =
    'emergency/order/update-status';
const String updateServiceEmergencyEndPoint =
    'emergency/order/update-order-services';
const String listServicesEmergencyEndPoint = 'emergency/order/list-services';
const String acceptOfferEmergencyEndPoint = 'emergency/order/accept-request';
const String rejectOfferEmergencyEndPoint = 'emergency/order/reject-request';
const String loginEmergencyEndPoint = 'emergency/login';
const String registerRequirementsDocEmergencyEndPoint =
    'emergency/register-requirements';
const String registerEmergencyEndPoint = 'emergency/register';
const String getProfileEmergencyEndPoint = 'emergency/user-profile';
const String startUpSlidesEmergencyEndPoint = 'emergency/start';
const String myOrdersBatteriesEmergencyEndPoint = 'emergency/order';
const String myOrdersWinchEmergencyEndPoint = 'emergency/order/check';
const String slidersEmergencyEndPoint = 'emergency/sliders';
const String productsEmergencyEndPoint = 'emergency/product/list/';
const String myTransactionEmergencyEndPoint = 'emergency/wallet/transactions';
const String myWithdrawalRequestsEmergencyEndPoint =
    'emergency/wallet/withdraw';
const String withdrawalMethodsEmergencyEndPoint =
    'emergency/wallet/withdraw/methods';
const String sentWithdrawalMethodEmergencyEndPoint =
    'emergency/wallet/withdraw';
const String myOrdersEmergencyEndPoint = 'emergency/order/:status';
const String batteriesProductsEmergencyEndPoint =
    'emergency/product/list/batteries/:status';
const String tiresProductsEmergencyEndPoint = 'emergency/product/list/tires/';
const String batteriesProductsByIdEmergencyEndPoint = 'emergency/product';
const String addTireEmergencyEndPoint = 'emergency/product/add-tire';
const String addBatteryEmergencyEndPoint = 'emergency/product/add-product';
const String detailsCarPartsOrderEmergencyEndPoint = 'emergency/order/details';
const String brandsEmergencyEndPoint = 'emergency/product/list-brands/products';
const String tiresBrandsEmergencyEndPoint =
    'emergency/product/list-brands/tires';

//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
// =============================================================
// =============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
//=============================================================
// =============================================================
// =============================================================
//=============================================================
//=============================================================

const String updateLocationEndPoint = 'winch/update-location';
const String updateOrderStatusEndPoint = 'winch/order/update-status';
const String getWinchOffersEndPoint = 'winch/order/check';
const String sentOfferEndPoint = 'winch/order/send-offer';
const String rejectOfferEndPoint = 'winch/order/reject-request';
const String loginWinchEndPoint = 'winch/login';
const String registerRequirementsDocWinchEndPoint =
    'winch/register-requirements';
const String registerWinchEndPoint = 'winch/register';
const String getProfileWinchEndPoint = 'winch/user-profile';
const String startUpSlidesWinchEndPoint = 'winch/start';
const String myOrdersBatteriesWinchEndPoint = 'winch/order';
const String myOrdersWinchWinchEndPoint = 'winch/order/check';
const String slidersWinchEndPoint = 'winch/sliders';
const String productsWinchEndPoint = 'winch/product/list/';
const String myTransactionEndPoint = 'winch/wallet/transactions';
const String myWithdrawalRequestsEndPoint = 'winch/wallet/withdraw';
const String withdrawalMethodsEndPoint = 'winch/wallet/withdraw/methods';
const String sentWithdrawalMethodEndPoint = 'winch/wallet/withdraw';
const String myOrdersWinchEndPoint = 'winch/order/:status';
const String batteriesProductsWinchEndPoint =
    'winch/product/list/batteries/:status';
const String tiresProductsWinchEndPoint = 'winch/product/list/tires/';
const String batteriesProductsByIdWinchEndPoint = 'winch/product';
const String addTireWinchEndPoint = 'winch/product/add-tire';
const String addBatteryWinchEndPoint = 'winch/product/add-product';
const String detailsCarPartsOrderWinchEndPoint = 'winch/order/details';
const String brandsWinchEndPoint = 'winch/product/list-brands/products';
const String tiresBrandsWinchEndPoint = 'winch/product/list-brands/tires';
const String carPartsSubmitPriceOfferEndPoint = 'car-parts-vendor/order/submit-price-offer';
const String updateCarPartsOrderStatusEndPoint = 'car-parts-vendor/order/update-status';
