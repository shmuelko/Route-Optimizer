public class Ctrl_RouteOptimisation {
	static Location START_POINT = Location.newInstance(32.197285, 34.879296);
	private List<Work_Order__c> lst_WorkOrders {get;set;}
	public String json_lst_WorkOrders {get;set;}
	public Work_Order__c dummyWD {get;set;}
	public Double startLat {get;set;}
	public Double startLon {get;set;} 
	public Boolean isOptimized {get;set;}
	public String firstNode {set;get;}
	public String secondNode {set;get;}
	public Double distance {get;set;}
	public Double thisDistance {get;set;}

	public Ctrl_RouteOptimisation(){
		dummyWD = new Work_Order__c();
		startLat = START_POINT.getLatitude();
		startLon = START_POINT.getLongitude();
		distance = 0;
		thisDistance = 0;
		isOptimized = false;
	}

	//Call the optimization utils class
	public void Optimize(){ 
		isOptimized = Utils.optimizeOneStepList(lst_WorkOrders, START_POINT, false, 'distance'); 
		json_lst_WorkOrders = JSON.serialize(lst_WorkOrders); 
		distance = Utils.getAllDistance(lst_WorkOrders, START_POINT);
	} 

	//Call the optimization utils class for one step
	public void OptimizeOneStep(){ 
		isOptimized = Utils.optimizeOneStepList(lst_WorkOrders, START_POINT, true, 'distance'); 
		json_lst_WorkOrders = JSON.serialize(lst_WorkOrders); 
		distance = Utils.getAllDistance(lst_WorkOrders, START_POINT);
	}  

	//Get the Work_Order__c to display on the map
	public void ShowLocations(){ 
		lst_WorkOrders = [SELECT Id, Location__latitude__s, Location__longitude__s, Date__c, Technician__c
							FROM Work_Order__c 
							WHERE Date__c =: dummyWD.Date__c AND Technician__c =: dummyWD.Technician__c ORDER BY Order_Number__c];
		json_lst_WorkOrders = JSON.serialize(lst_WorkOrders);
	}

	//Swap two nodes
	public void SwapNodes(){ 
		if(!String.isEmpty(firstNode) && !String.isEmpty(secondNode)  && firstNode != secondNode){
			Utils.swap(lst_WorkOrders, Integer.valueOf(firstNode), Integer.valueOf(secondNode)); 
			json_lst_WorkOrders = JSON.serialize(lst_WorkOrders);
			distance = Utils.getAllDistance(lst_WorkOrders, START_POINT);
		}
	}

	//Check the distance between two nodes
	public void checkDistance(){
		if(firstNode != secondNode){
			thisDistance = Location.getDistance(Utils.getLocation(lst_WorkOrders[Integer.valueOf(firstNode)]), Utils.getLocation(lst_WorkOrders[Integer.valueOf(secondNode)]), 'km');
		}
	}
}