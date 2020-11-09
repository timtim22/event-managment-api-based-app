$(document).ready(function(){
  var confirmationResult;
  var firebaseConfig = {
    apiKey: "AIzaSyCb93NfGvijAAZ9RcKa9FCppbQl5IosLXs",
    authDomain: "mygo-8afd5.firebaseapp.com",
    projectId: "mygo-8afd5",
    storageBucket: "",
    messagingSenderId: "838691930681",
    appId: "1:838691930681:web:ddb709b00929da270e83e8"
  };
  
  firebase.initializeApp(firebaseConfig);
  // Create a Recaptcha verifier instance globally
       // Calls submitPhoneNumberAuth() when the captcha is verified
       window.recaptchaVerifier = new firebase.auth.RecaptchaVerifier(
         "recaptcha-container_new",
         {
           size: "invisible",
           callback: function(response) {
             submitPhoneNumberAuth();
           }
         }
       );
  
       // This function runs when the 'sign-in-button' is clicked
       // Takes the value from the 'phoneNumber' input and sends SMS to that phone number
      
       $(document).on('click','input#verify_phone_number', function(event){
        event.preventDefault();
        submitPhoneNumberAuth();
      });//click
     
      function submitPhoneNumberAuth() {
        var phoneNumber = document.getElementById("phoneNumber").value;
        var appVerifier = window.recaptchaVerifier;
        firebase
          .auth()
          .signInWithPhoneNumber(phoneNumber, appVerifier)
          .then(function(result) {
            confirmationResult = result;
             $("#phoneNumber").hide();
             $('input#verify_phone_number').hide();
             $("#recaptcha-container_new").hide();
             $('input#code').show();
             $("p#resend_p").show();
             $('input#confirm-code').show();
          })
          .catch(function(error) {
            var msg = error["message"];
            console.log('msg',error["message"]);
             $("div#invalid_phone_number").show();
             $("div#invalid_phone_number").html(msg);
          });
      }

      recaptchaVerifier.render().then(function(widgetId) {
        window.recaptchaWidgetId = widgetId;
      });
      
       // This function runs when the 'confirm-code' button is clicked
       // Takes the value from the 'code' input and submits the code to verify the phone number
       // Return a user object if the authentication was successful, and auth is complete
      
      $(document).on('click','input#confirm-code',function(event){
        event.preventDefault();
        var code = document.getElementById("code").value;
        confirmationResult
          .confirm(code)
          .then(function(result) {
            var user = result.user;
            var token = $("input#auth_token").val();
            var phone = $("input#phoneNumber").val();
            console.log('ph',phone);
            $.ajax({
              type: 'post',
              url: '/verify-phone',
              data: {
               authenticity_token: token,
               phone_number: phone
              },
              success: function(resp){
                console.log(resp);
                $("#phone_verification_success").show();
                $("#phone_verification_success").html(resp.message);
                $("input#code").hide();
                $("input#confirm-code").hide();
                $("a#login_link").show();
              }
            });//ajax
          

          })
          .catch(function(error) {
            console.log(error);
            $("div#phone_verification_error").show()
            $("div#phone_verification_error").html("Phone verification failed.");
          });
      });//click
      
     
       //This function runs everytime the auth state changes. Use to verify if the user is logged in
       firebase.auth().onAuthStateChanged(function(user) {
         if (user) {
          
           console.log("USER LOGGED IN");
         } else {
           // No user is signed in.
           console.log("USER NOT LOGGED IN");
         }
       });

       $(document).on('click','a#resend_code',function(event){
         location.reload();
       });//click

});//ready
