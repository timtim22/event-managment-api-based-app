$(document).ready(function(){
   $(document).on('click','#submit',function(e){
     $("#preloader").show();
       $("#success_page").hide();
       $("#error_page").hide();
       e.preventDefault();
       $.ajax({
        type: 'get',
        url:'/send-email',
        data: {
            name: $("#name").val(),
            email: $("#email").val(),
            message: $(".message").val(),
            subject: $(".subject").val()
        },
        success: function(resp){
            $("#preloader").hide();
            if(resp.success == true) {
                $("#success_page").show();
            }
            else {
                $("#error_page").show();
                $(".u_name").html("<strong>" + $("#name").val() + "</strong>");
            }
            console.log('resp',resp.success);
        }
    })//ajax
   });//click
   
})//clikc