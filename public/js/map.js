 $(document).ready(function(){
	  	$(".circle").hide();
	  	$(".ireland_circle").hide();
	  	fadeCircle();
	  	setTimeout(function(){
	  		IrfadeCircle();
	  	}, 1200);
	  });//ready
		function fadeCircle() {
		    $("div.circle").fadeOut(500, function() {
		    		$("#ofc_name").text("Pakistan");
		    	setTimeout(function(){
		    		$("#animation").addClass('animate');
		    		$("#ofc_name").addClass('address_fadeout');
		    	}, 1000);
		    	setTimeout(function(){
		    		$("#ofc_name").addClass('address_fadeout');
		    	}, 3000);
		        $(this).fadeIn(500, fadeCircle());
		    });// fadeout
		}

		function IrfadeCircle() {
		    $(".ireland_circle").fadeOut(500, function() {
		    		$("#ireland_ofc_name").text("Ireland");
		    	setTimeout(function(){
		    		$("#ireland_animation").addClass('animate');
		    		$("#ireland_ofc_name").addClass('address_fadeout');
		    	}, 1000);
		    	setTimeout(function(){
		    		$("#ireland_ofc_name").addClass('address_fadeout');
		    	}, 3000);
		        $(this).fadeIn(500, IrfadeCircle());
		    });
		}
