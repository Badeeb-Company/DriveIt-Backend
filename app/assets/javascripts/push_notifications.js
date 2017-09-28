function change_selection(value)
{
	  var url = '/areas.json?city_id=' + value
	  $("#areas").empty();
	  $.get(url, function(data) 
	  {
	  		$('#areas').append($("<option></option>")
	                    .attr("value","")
	                    .text("Select all Areas")); 
		  	// console.log(data);
		  	for(var i=0; i < data.length; i++)
		  	{
		    	$('#areas').append($("<option></option>")
	                    .attr("value",data[i]["id"])
	                    .text(data[i]["name"])); 
		    }
	  });
}

function calculateLength()
{
	var length = $("#push_text").val().length;
	var push_length = $("#push_length");
	var push_text = $("#push_length");
	push_length.html(length);
	console.log(push_length, length);
	if(length > 110)
	{
		push_length.css("color","red");
	}
	else
	{
		push_length.css("color","green");
	}
}