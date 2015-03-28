/**
	This factory contains common/general functions used by all the controlles
*/
arkonLEDApp.
factory('commonFactory', function (){
	var factory = {};
	var $scope; 

    // Use this url only when working locally, use relative path best when deploying to AWS
	factory.baseUrl = "http://ec2-54-84-156-215.compute-1.amazonaws.com";
	//factory.baseUrl = "..";


	// Update scope from outside component
	factory.updateScope = function(scope){
		$scope = scope;
	};

	// Get list of projects from web services
    factory.toFormattedNumber = function(number){
        return Number(number).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    };

    factory.calculateChartPoints = function(calculationsData){
		var stats = [];
		if($scope.activeView == 'expeditedShipping' && $scope.paymentType == 'upFrontPurchase'){
			for (var i = 0; i < 10; i++) {
				stats[i] = {
					year: (new Date().getFullYear() + i).toString(),
					existingPowerCost: Number(calculationsData.existingYearByYearPowerCost[i]),
					existingMantenanceCost: Number(calculationsData.existingYearByYearPowerCost[i]) + Number(calculationsData.existingYearlyMaintenanceCost),
					proposedPowerCost: Number(calculationsData.proposedYearByYearPowerCost[i]),
					LEDLeasePayment: Number(calculationsData.proposedYearByYearPowerCost[i]),
					savings: Number(calculationsData.yearByYearSavings[i])
				};
			}
		}
		else if($scope.activeView == 'standardShipping' && $scope.paymentType == 'upFrontPurchase'){
			for (var i = 0; i < 10; i++) {
				stats[i] = {
					year: (new Date().getFullYear() + i).toString(),
					existingPowerCost: Number(calculationsData.existingYearByYearPowerCost[i]) ,
					existingMantenanceCost: Number(calculationsData.existingYearByYearPowerCost[i]) + Number(calculationsData.existingYearlyMaintenanceCost),
					proposedPowerCost: Number(calculationsData.proposedYearByYearPowerCost[i]),
					LEDLeasePayment: Number(calculationsData.proposedYearByYearPowerCost[i]),
					savings: Number(calculationsData.yearByYearSavings[i])
				};
			}
		}
		else if($scope.activeView == 'expeditedShipping' && $scope.paymentType == 'leaseToOwn'){
			for (var i = 0; i < 10; i++) {
				stats[i] = {
					year: (new Date().getFullYear() + i).toString(),
					existingPowerCost: Number(calculationsData.existingYearByYearPowerCost[i]),
					existingMantenanceCost: Number(calculationsData.existingYearByYearPowerCost[i]) + Number(calculationsData.existingYearlyMaintenanceCost),
					proposedPowerCost: Number(calculationsData.proposedYearByYearPowerCost[i]),
					LEDLeasePayment: i < 5 ? Number(calculationsData.proposedYearByYearPowerCost[i]) + Number(calculationsData.yearlyLeasePaymentExpedited):
                    Number(calculationsData.proposedYearByYearPowerCost[i]),
					savings: Number(calculationsData.yearByYearSavings[i])
				};
			}
		}
		else if($scope.activeView == 'standardShipping' && $scope.paymentType == 'leaseToOwn'){
			for (var i = 0; i < 10; i++) {
				stats[i] = {
					year: (new Date().getFullYear() + i).toString(),
					existingPowerCost: Number(calculationsData.existingYearByYearPowerCost[i]),
					existingMantenanceCost: Number(calculationsData.existingYearByYearPowerCost[i]) + Number(calculationsData.existingYearlyMaintenanceCost),
					proposedPowerCost: Number(calculationsData.proposedYearByYearPowerCost[i]),
					LEDLeasePayment: i < 5 ? Number(calculationsData.proposedYearByYearPowerCost[i]) + Number(calculationsData.yearlyLeasePaymentStandard): Number(calculationsData.proposedYearByYearPowerCost[i]),
					savings: Number(calculationsData.yearByYearSavings[i])
				};
			}
		}
		

		return stats;
	};

	return factory;
});