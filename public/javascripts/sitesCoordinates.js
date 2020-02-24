function setNewCoordinates()
	{
		var googleLatitude = document.getElementById('mapLatitude');
		var googleLongitude = document.getElementById('mapLongitude');
		point = new google.maps.LatLng(googleLatitude.value,googleLongitude.value);
		alert(point);
		map.setCenter(point);
		marker.setPosition(point);
		//map.setCenter(googleLongitude);
		//alert(googleLongitude.value+","+googleLatitude.value);
		//center: new google.maps.LatLng(googleLongitude.value , googleLatitude.value"),
	}
	//
    // initialize map
    //
	 var map = new google.maps.Map(document.getElementById("mapDiv"), {
      center: new google.maps.LatLng(document.getElementById('mapLatitude').value,  document.getElementById('mapLongitude').value),
      zoom: 10,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    
    //
    // initialize marker
    //
    var marker = new google.maps.Marker({
      position: map.getCenter(),
      draggable: true,
      map: map
    });
  google.maps.event.addDomListener(window, "load", function() {
    //
    // intercept map and marker movements and print out the value
    //
    google.maps.event.addListener(map, "idle", function() 
    {
      		//document.getElementById("printCoordinates").innerHTML = "Latitude: " + map.getCenter().lat().toFixed(6) + "<br>Longitude: " + map.getCenter().lng().toFixed(6);	
    		document.getElementById("mapLatitude").value =	map.getCenter().lat().toFixed(6);
    		document.getElementById("mapLongitude").value = map.getCenter().lng().toFixed(6);
    });
    google.maps.event.addListener(marker, "dragend", function(mapEvent) {
      map.panTo(mapEvent.latLng);
    });
  });
