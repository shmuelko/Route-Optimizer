/**
 * 	Utils for all the functions.
 **/ 
public class Utils{
	/**
	* 	Utils to optimize the customer list and retun the most efficient way (ordered list).
	**/
	public static Boolean optimizeOneStepList(List<Work_Order__c> lst_WorkOrders, Location startPoint, Boolean oneStep, String mode){
		Boolean isDone = true;
		Integer maxIterations = lst_WorkOrders.size();
		try{
			while(isDone && maxIterations > 0){
				if(lst_WorkOrders.size() < 3){
					return true;
				}

				//Check if there is a better route with the start point at the start
				checkListWithBeginingStartPoint(lst_WorkOrders, startPoint, isDone, oneStep, mode);

				//Check if there is a better route with the point before and after the start point
				checkListWithMiddleStartPoint(lst_WorkOrders, startPoint, isDone, oneStep, mode);

				// Run over all the points and check if there is a point that can be swapt with shorter path
				for(Integer i = 1; isDone && i < lst_WorkOrders.size() -1; i++){
					for(Integer j = i+1; isDone && j < lst_WorkOrders.size() -1; j++){
						if(j == i + 1){
							if(checkDistance_Close(getLocation(lst_WorkOrders[i-1]), getLocation(lst_WorkOrders[i]),
													getLocation(lst_WorkOrders[j]), getLocation(lst_WorkOrders[j+1]), mode)){
								swap(lst_WorkOrders, i, j); 
								if(oneStep){
									isDone = false;								
								}
							}
						}else{
							if(checkDistance(getLocation(lst_WorkOrders[i-1]), getLocation(lst_WorkOrders[i]), getLocation(lst_WorkOrders[i+1]),
												getLocation(lst_WorkOrders[j-1]), getLocation(lst_WorkOrders[j]), getLocation(lst_WorkOrders[j+1]), mode)){
								swap(lst_WorkOrders, i, j); 
								if(oneStep){
									isDone = false;								
								}
							}					
						} 
					}
				}

				//Check if there is a better route with the start point at the end
				checkListWithEndStartPoint(lst_WorkOrders, startPoint, isDone, oneStep, mode);
				maxIterations--;
			}
		}catch(Exception ex){
			System.debug('Error -Utils -optimizeOneStepList: ' + ex.getLineNumber() +', ' + ex.getMessage());
		}
		
		return isDone;
	}

	//Check if there is a better route with the start point at the start
	public static void checkListWithBeginingStartPoint(List<Work_Order__c> lst_WorkOrders, Location startPoint, Boolean isDone, Boolean oneStep, String mode){
		if( isDone && checkDistance_Close(startPoint, getLocation(lst_WorkOrders[0]), getLocation(lst_WorkOrders[1]), getLocation(lst_WorkOrders[2]), mode)){
			swap(lst_WorkOrders, 0, 1); 
			isDone = false;
		}
		for(Integer j = 2; isDone && j < lst_WorkOrders.size(); j++){
			if(j+1 >= lst_WorkOrders.size()){
				if(checkDistance(startPoint, getLocation(lst_WorkOrders[0]), getLocation(lst_WorkOrders[1]), getLocation(lst_WorkOrders[j-1]), getLocation(lst_WorkOrders[j]), startPoint, mode)){
					swap(lst_WorkOrders, 0, j); 
					if(oneStep){
						isDone = false;								
					}
				}
			}else if(checkDistance(startPoint, getLocation(lst_WorkOrders[0]), getLocation(lst_WorkOrders[1]), getLocation(lst_WorkOrders[j-1]), getLocation(lst_WorkOrders[j]), getLocation(lst_WorkOrders[j+1]), mode)){
				swap(lst_WorkOrders, 0, j); 
				if(oneStep){
					isDone = false;								
				}								
			}
		}
	}

	//Check if there is a better route with the point before and after the start point
	public static void checkListWithMiddleStartPoint(List<Work_Order__c> lst_WorkOrders, Location startPoint, Boolean isDone, Boolean oneStep, String mode){
		if( isDone && checkDistance(getLocation(lst_WorkOrders[lst_WorkOrders.size() -2]), getLocation(lst_WorkOrders[lst_WorkOrders.size() -1]), startPoint,
							startPoint, getLocation(lst_WorkOrders[0]), getLocation(lst_WorkOrders[1]), mode)){
			swap(lst_WorkOrders, 0, lst_WorkOrders.size() -1); 
			if(oneStep){
				isDone = false;								
			}
		}

		if(checkDistance_Close(getLocation(lst_WorkOrders[lst_WorkOrders.size() -3]), getLocation(lst_WorkOrders[lst_WorkOrders.size() -2]), getLocation(lst_WorkOrders[lst_WorkOrders.size() -1]), startPoint, mode)){
			swap(lst_WorkOrders, lst_WorkOrders.size() -2, lst_WorkOrders.size() -1); 
			if(oneStep){
				isDone = false;								
			}
		}
	}

	//Check if there is a better route with the start point at the end
	public static void checkListWithEndStartPoint(List<Work_Order__c> lst_WorkOrders, Location startPoint, Boolean isDone, Boolean oneStep, String mode){
		for(Integer j = 1; isDone && j < lst_WorkOrders.size()-2; j++){
			if(checkDistance(getLocation(lst_WorkOrders[j-1]), getLocation(lst_WorkOrders[j]), getLocation(lst_WorkOrders[j +1]), 
								getLocation(lst_WorkOrders[lst_WorkOrders.size() -2]),getLocation(lst_WorkOrders[lst_WorkOrders.size() -1]), startPoint, mode)){
				swap(lst_WorkOrders, j, lst_WorkOrders.size() -1); 
				if(oneStep){
					isDone = false;								
				}
			}
		}  
		if(isDone && checkDistance_Close(getLocation(lst_WorkOrders[lst_WorkOrders.size() -3]), getLocation(lst_WorkOrders[lst_WorkOrders.size() -2]), 
											getLocation(lst_WorkOrders[lst_WorkOrders.size() -1]), startPoint, mode)){
			swap(lst_WorkOrders, lst_WorkOrders.size() -2, lst_WorkOrders.size() -1); 
			if(oneStep){
				isDone = false;								
			}
		}
	}

	//Swap two points in the list by indexes
	public static void swap (List<Work_Order__c> lst_WorkOrders, Integer firstIndex, Integer secondIndex){
		if(firstIndex > secondIndex){
			Integer tempInt = secondIndex;
			secondIndex = firstIndex;
			firstIndex = tempInt;
		}
		Work_Order__c tempWO1 = lst_WorkOrders.remove(firstIndex);
		Work_Order__c tempWO2 = lst_WorkOrders.remove(secondIndex-1);
		if(firstIndex >= lst_WorkOrders.size()){
			lst_WorkOrders.add(tempWO2);
		}else{
			lst_WorkOrders.add(firstIndex, tempWO2);			
		}
		if(secondIndex >= lst_WorkOrders.size()){
			lst_WorkOrders.add(tempWO1);
		}else{
			lst_WorkOrders.add(secondIndex, tempWO1);			
		}
	}
 	
 	//Calculate all the distance of Work_Order__c list
	public static Double getAllDistance(List<Work_Order__c> lst_WorkOrders, Location startPoint){
		if(lst_WorkOrders.isEmpty()){
			return 0;
		}
		Double dist = Location.getDistance(startPoint, getLocation(lst_WorkOrders[0]) , 'km');
		for(Integer i = 0; i < lst_WorkOrders.size() -1; i++){
			dist += Location.getDistance(getLocation(lst_WorkOrders[i]), getLocation(lst_WorkOrders[i+1]) , 'km'); 
		}
		dist += Location.getDistance(getLocation(lst_WorkOrders[lst_WorkOrders.size() -1]), startPoint, 'km');
		return dist;
	}

	//Check distance between two points to check if it will improve the global distance
	public static Boolean checkDistance (Location locA1, Location locA2, Location locA3, Location locB1, Location locB2, Location locB3, String mode){
		if(mode.equalsIgnoreCase('driveTime')){
			return checkIsShorterByTime(getStringLocation(locA1), getStringLocation(locA2), getStringLocation(locA3), getStringLocation(locB1), getStringLocation(locB2), getStringLocation(locB3));
		}else{
			return checkIsShorter(locA1, locA2, locA3, locB1, locB2, locB3);
		}
	}

	//Check distance between two close points points to check if it will improve the global distance
	public static Boolean checkDistance_Close (Location locA1, Location locA2, Location locB1, Location locB2, String mode){
		if(mode.equalsIgnoreCase('driveTime')){
			return checkIsShorterByTime_Close(getStringLocation(locA1), getStringLocation(locA2), getStringLocation(locB1), getStringLocation(locB2));
		}else{
			return checkIsShorter_Close(locA1, locA2, locB1, locB2);
		}
	}

	public static Boolean checkIsShorter (Location locA1, Location locA2, Location locA3, Location locB1, Location locB2, Location locB3){
		Double distA1 = Location.getDistance(locA1, locA2, 'km');
		Double distA2 = Location.getDistance(locA2, locA3, 'km');

		Double distA3 = Location.getDistance(locB1, locB2, 'km');
		Double distA4 = Location.getDistance(locB2, locB3, 'km');

		Double distB1 = Location.getDistance(locA1, locB2, 'km');
		Double distB2 = Location.getDistance(locB2, locA3, 'km');

		Double distB3 = Location.getDistance(locB1, locA2, 'km');
		Double distB4 = Location.getDistance(locA2, locB3, 'km');
		if( (distA1 + distA2 + distA3 + distA4) > (distB1 + distB2 + distB3 + distB4)){
			return true;
		}
		return false;
	}


	public static Boolean checkIsShorterByTime (String locA1, String locA2, String locA3, String locB1, String locB2, String locB3){
		Integer timeA1 = (new googleMaps(locA1, locA2)).travelTime;
		Integer timeA2 = (new googleMaps(locA2, locA3)).travelTime;

		Integer timeA3 = (new googleMaps(locB1, locB2)).travelTime;
		Integer timeA4 = (new googleMaps(locB2, locB3)).travelTime;

		Integer timeB1 = (new googleMaps(locA1, locB2)).travelTime;
		Integer timeB2 = (new googleMaps(locB2, locA3)).travelTime;

		Integer timeB3 = (new googleMaps(locB1, locA2)).travelTime;
		Integer timeB4 = (new googleMaps(locA2, locB3)).travelTime;
		if( (timeA1 + timeA2 + timeA3 + timeA4) > (timeB1 + timeB2 + timeB3 + timeB4)){
			return true;
		}
		return false;
	}


	public static Boolean checkIsShorter_Close (Location locA1, Location locA2, Location locB1, Location locB2){
		Double distA1 = Location.getDistance(locA1, locA2, 'km');
		Double distA3 = Location.getDistance(locB1, locB2, 'km');

		Double distB1 = Location.getDistance(locA1, locB1, 'km');
		Double distB3 = Location.getDistance(locA2, locB2, 'km');
		if((distA1 +  distA3) >  (distB1 +  distB3)){
			return true;
		}
		return false;
	}

	public static Boolean checkIsShorterByTime_Close (String locA1, String locA2, String locB1, String locB2){
		Integer distA1 = (new googleMaps(locA1, locA2)).travelTime;
		Integer distA3 = (new googleMaps(locB1, locB2)).travelTime;

		Integer distB1 = (new googleMaps(locA1, locB1)).travelTime;
		Integer distB3 = (new googleMaps(locA2, locB2)).travelTime; 
		if((distA1 +  distA3) >  (distB1 +  distB3)){
			return true;
		}
		return false;
	}

	public static Location getLocation (Work_Order__c workOrd){
		return Location.newInstance(workOrd.Location__latitude__s, workOrd.Location__longitude__s);
	}

	public static String getStringLocation (Location loc){
		return String.valueOf(loc.getLatitude()) +','+String.valueOf(loc.getLongitude());
	}
}