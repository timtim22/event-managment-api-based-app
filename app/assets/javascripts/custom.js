$(document).ready(function(){
  var checkboxes = [];
   $(document).on('change','select#type', function(event){
   	   if($(this).val() == '2') {
       $("div.business_details").show();
    }
    else {
    	 $("div.business_details").hide();
    }
   });//change 
   $(document).on('click','#allow_additional_media', function(event){
   	 if($(this).is(":checked") == true) {
   	  $("div.additional_media_wrapper").show();
   }
   else {
   	  $("div.additional_media_wrapper").hide();
   } 
   });//click

   $(document).on('click','#update_password_modal_btn', function(event){
        event.preventDefault();
        let validated = false;
        $("#modalChangePassword input").each(function(index,value){
          if($(value).val() == '') {
            $(value).css('border-color','red');
            validated = false;
          }
          else {
            validated = true;
            $(value).css('border-color','transparent');
          }
       });//each
       
       if(validated == true) {
        $('form#change_password_form').submit(); 
      }
   });//click
    
   $(document).on('submit', 'form#change_password_form',function(event){
     $('div.alert-danger').hide();
     $(".flash_alert").hide();
      event.preventDefault();
      var formData = new FormData(this);
      var url = "/admin/user/update-password";
      $.ajax({
      url: url, 
      type: "POST",             
      data: formData, 
      contentType: false,        
      cache: false,           
      processData:false,       
      success: function(data) {
          console.log(data.success);
             if(data.success == true) {
               $("div.flash_alert").show();
               $('div.flash_alert').text(data.message);
             }
             else {
              $("div.alert-danger").show()
              $('div.alert-danger').text(data.message);
             }
           
             $("#modalChangePassword").modal('hide');
            //location.reload();
        }  
      });//ajax
   });//submit

   $(document).on('click','#update_user_info_modal_btn', function(event){
     event.preventDefault();
     $('form#update_user_info_form').submit(); 
});//click

$(document).on('submit', 'form#update_user_info_form',function(event){
  $('div.alert-danger').hide();
 $(".flash_alert").hide();
  event.preventDefault();
  var formData = new FormData(this);
  var url = "/admin/user/update-info";
  $.ajax({
  url: url, 
  type: "POST",             
  data: formData, 
  contentType: false,        
  cache: false,           
  processData:false,       
  success: function(data) {
      console.log(data.success);
         if(data.success == true) {
           $("div.flash_alert").show();
           $('div.flash_alert').text(data.message);
         }
         else {
          $("div.alert-danger").show()
          $('div.alert-danger').text(data.message);
         }
       
         $("#modalUpdateInfo").modal('hide');
        //location.reload();
    }  
  });//ajax
});//submit

   $(document).on('click','.edit_event_checkbox',function(event){
     $('.appended').remove();
    console.log($(this).parent().attr('class'));
    var value = '';
    if($(this).is(":checked") == true) {
      value = true;
    }
    else if($(this).is(":checked") == false) {
      value = false;
    }
    var hidden = $(this).next('input');
    hidden.val(value)
   });//click

   //Data table
   $(document).ready(function() {
    $('#event_listing_table').DataTable();
   });

   //Date picker birth_date
   $('.date').datepicker({
     dateFormat: 'yy-mm-dd'
    });

    $('#import_start_date').datepicker({
      dateFormat: 'yy-mm-dd'
     });

     $('#import_end_date').datepicker({
      dateFormat: 'yy-mm-dd'
     });
   //time picker
   $('input#start_time').timepicker({
    timeFormat: 'HH:mm:ss',
    interval: 60,
    dynamic: false,
    dropdown: true,
    scrollbar: true
});



$('input#validity_time').timepicker({
  timeFormat: 'HH:mm:ss',
  interval: 60,
  dynamic: false,
  dropdown: true,
  scrollbar: true
});

//Inline DateTimePicker Example
/*
  timeFormat: 'h:mm p',
  interval: 60,
  minTime: '10',
  maxTime: '12:00pm',
  defaultTime: '11',
  startTime: '08:00',
  dynamic: false,
  dropdown: true,
  scrollbar: true
*/
$('input#end_time').timepicker({
  timeFormat: 'HH:mm:ss',
  interval: 60,
  dynamic: false,
  dropdown: true,
  scrollbar: true
});

$(document).on('click','#add_social_media_links',function(event){
  if($(this).is(":checked") ==  true) {
    $('.social_wrapper').show();
  }
  else {
    $('.social_wrapper').hide();
  }
});//click

$input = $("#search_friends_input");
var options = {
  getValue: "first_name",
  url: function(phrase) {
    return "/admin/user/search-friends.json?q=" + phrase;
  },
  categories: [
    {
      listLocation: "friends",
      header: "<strong>Suggested Friends</strong>",
    } 
  ],
  list: {
    onChooseEvent: function() {
      var url = $input.getSelectedItemData().url
      var avatar = $input.getSelectedItemData().avatar
      var name = $input.getSelectedItemData().first_name + " " + $input.getSelectedItemData().last_name;
      var current_user_id = $input.getSelectedItemData().current_user_id;
      var friend_id = $input.getSelectedItemData().friend_id;
      console.log('friend_id_os',friend_id);
      var is_friend = $input.getSelectedItemData().is_friend;  
      if(current_user_id ==  friend_id) {
        $("#add_friend_modal button#add_friend_btn").hide();
        $("#add_friend_modal_heading").html(name + "<br>&nbsp;&nbsp;(you)");
      }
      else {
      
        $("#add_friend_modal button#add_friend_btn").show();
        $("#add_friend_modal_heading").text(name);
      }
     
      $.ajax({
         type: 'get',
         url: '/admin/check-request?id=' + friend_id,
         success:function(resp) {
           if(resp.status == 'pending') {
            $("#add_friend_modal button#add_friend_btn").attr('disabled', true);
            $("#add_friend_modal button#add_friend_btn").text('Request sent.');
           }
           else if(resp.status == 'accepted') {
            $("#add_friend_modal button#add_friend_btn").attr('disabled', true);
            $("#add_friend_modal button#add_friend_btn").text('Friend');
           } 
           else {
            $("#add_friend_modal button#add_friend_btn").attr('disabled', false);
            $("#add_friend_modal button#add_friend_btn").text('Add Friend');
           }
         }
       });//ajax
      $input.val("")
       $("#add_friend_modal img").attr('src',avatar);
       $("#add_friend_modal img").attr('onError',"this.onerror=null;this.src='/assets/avatar.png';");
  
       $("#add_friend_modal button#add_friend_btn").attr('data-url',url);
       $('#add_friend_modal').modal('show');
    }
  }
}
$input.easyAutocomplete(options);

$(document).on('click','#add_friend_btn', function(event){
   event.preventDefault();
   var url = $(this).data('url');
   $.ajax({
     url: url,
     success: function(resp) {
       console.log('resp',resp);
       if(resp.success ==  true) {
         $('.alert-success').html(resp.message);
         $('.alert-success').show();
       }
       else {
          $(".alert-danger").html(resp.message);
          $('.aler-danger').show();
       }
       $("#add_friend_modal").modal('hide');
     }
   });//aja
});//click
//======================= Notifications ================

function getNotifications() {
  $('div.notifications_wrapper').empty();
  $.ajax({
    type: "get",
    url: "/admin/get-notificaitons.json",
    success: function(data) {
      $.each(data, function(index, value){
        if(value.length == '0') {
          $("a#clear_notifications").hide();
          $('p.dropdown-header').html("No notificaitons.");
        }
        else {
          $("a#clear_notifications").show();
        }
        $.each(value, function(index,value){
          var notification_url = value.notification_url;
          var html = '<a href="' + notification_url + '"' + 'class="dropdown-item">'
                 + '<div class="item-thumbnail">'
                 + '<div class="item-icon">'
                 + '<img src="' + value.actor_avatar + ' " ' + 'onerror="this.onerror=null;this.src="' + value.image_link +  '"' + ';">'
                 + '</div>'
                 + '</div>'
                 + '<div class="item-content">'
                 + '<h6 class="font-weight-normal">' + value.action.substr(0, 80) + '...' + '</h6>'
                 +  '<p class="font-weight-light small-text mb-0 text-muted">'
                 +  value.time 
                 +  '</p>'
                 + '</div>'
                 + '</a>';
                
                 $('div.notifications_wrapper').append(html);
                 if(value.unread_notification_count > 0) {
                   $("span.count").show();
                   $("span.count").html(value.unread_notification_count);
                 }
                });//each
      });//each
    }
  });//ajax
}

$(document).on('click','.fa-bell',function(event){
  $.ajax({
   type: 'get',
   url: '/admin/mark-as-read',
   success: function(data) {
     $("span.count").hide();
   }
  });//ajax
});//click

function getRealTimeNotifications() {
      var counter = 0;
     //Get notifications count from db
     $.ajax({
       url: '/admin/get-notifications-count',
       type: 'get',
       success: function(resp) {
         counter = resp.data.count;
         listenToPubNubAndPrepend(counter);
       }
     })
   
}

function listenToPubNubAndPrepend(counter) {
  var pubnub = new PubNub({
  publishKey: gon.publish_key,
  subscribeKey: gon.subscribe_key
}); // Your PubNub keys here. Get them from https://dashboard.pubnub.com.
// var box = document.getElementById("box"), input = document.getElementById("input"), channel = 'chat';
var channel = gon.current_user_channel;
pubnub.subscribe({channels: [channel]}); // Subscribe to a channel.
console.log("counter inside real time ", counter);
pubnub.addListener({message: function(m) {
    counter ++;
    $('p.dropdown-header').html("Notificaitons");
    $("a#clear_notifications").show();
    var notification_url = m.message.notification_url;
    var avatar = m.message.avatar;
    var action = m.message.action;
    var time = m.message.time;
    var html = '<a href="' + notification_url + '"' + 'class="dropdown-item">'
    + '<div class="item-thumbnail">'
    + '<div class="item-icon">'
    + '<img src="' + avatar + ' " ' + 'onerror="this.onerror=null;this.src="' + avatar +  '"' + ';">'
    + '</div>'
    + '</div>'
    + '<div class="item-content">'
    + '<h6 class=""><strong>' + action + '</strong></h6>'
    +  '<p class="font-weight-light small-text mb-0 text-muted">'
    +   time 
    +  '</p>'
    + '</div>'
    + '</a>';
    $('div.notifications_wrapper').prepend(html);
    $("span.count").show();
   // counter = parseInt(counter) + 1;
    $("span.count").html(counter);
  }});
}

$(document).on('click','a#clear_notifications',function(event){
  $.ajax({
    url: "/admin/clear-notifications",
    type: "get",
    success: function(resp) {
      getNotifications();
    }
  });//ajax
});//click
getNotifications();
getRealTimeNotifications();
// alert('yes here from assets pipeline');
// var pubnub = new PubNub({
//   publishKey : 'pub-c-70ca7701-1c67-4628-ada1-de6885038147',
//   subscribeKey : 'sub-c-5709c42a-2b99-11ea-9e12-76e5f2bf83fc'
// }); // Your PubNub keys here. Get them from https://dashboard.pubnub.com.
// var box = document.getElementById("box"), input = document.getElementById("input"), channel = 'chat';

// pubnub.subscribe({channels: [channel]}); // Subscribe to a channel.

// pubnub.addListener({message: function(m) {
//      box.innerHTML = (''+m.message).replace( /[<>]/g, '' ) + '<br>' + box.innerHTML; // Add message to page.
//   }});

// input.addEventListener('keypress', function (e) {
//     (e.keyCode || e.charCode) === 13 && pubnub.publish({ // Publish new message when enter is pressed. 
//         channel : channel, message : input.value, x : (input.value='')
//     });
// });

$(document).on('click','#import_event_btn', function(){
  $(".spinner-border").show();
  $("#import_events_modal").modal('show');
});//click

//setup before functions
var typingTimer;                //timer identifier
var doneTypingInterval = 4000;  //time in ms, 5 second for example
var $input = $('input.location');

//on keyup, start the countdown
$input.on('keyup', function () {
  clearTimeout(typingTimer);
  typingTimer = setTimeout(doneTyping, doneTypingInterval);
});

$input.on('focusout', function () {
  clearTimeout(typingTimer);
  typingTimer = setTimeout(doneTyping, doneTypingInterval);
});
//on keydown, clear the countdown 
$input.on('keydown', function () {
  clearTimeout(typingTimer);
});

//user is "finished typing," do something
function doneTyping () {
  if($("input#location").val() != '') {
    $.ajax({
     type: 'post',
     url: '/admin/get-latlng',
     data: {
       name: $("input#location").val(),
     },
     success: function(resp) {
       console.log(resp.data);
        if(resp.success == true) {
          $('input#lat').val(resp.data.lat);
          $('input#lng').val(resp.data.lng);
        }
        else {
          $("span#location_error").show();
          $("span#location_error").text(resp.message);
        } 

     }
    });//ajax  
}
}

$(document).on('change','input#competition_location',function(event){
  if($("input#location").val() != '') {
      $.ajax({
       type: 'get',
       url: '/admin/get-latlng?name=' + $("input#competition_location").val(),
       success: function(resp) {
         console.log(resp.data);
          if(resp.success == true) {
            $('input#lat').val(resp.data.lat);
            $('input#lng').val(resp.data.lng);
          }
          else {
            $("span#location_error").show();
            $("span#location_error").text(resp.message);
          } 

       }
      });//ajax  
  }
});//change
 
function setSelectValue() {
  if($("#price_type").val() != "free") {
    $("div.price_div").show();
 }
 else {
  $("div.price_div").hide();
  $("input#price").val('');
 }
}
setSelectValue();

$(document).on('change','#price_type',function(e){
   if($("#price_type").val() != "free") {
      $("div.price_div").show();
   }
   else {
    $("div.price_div").hide();
    $("input#price").val('0');
   }

});//change

 $(".select_multi").chosen({
   width: '50%',
   max_selected_options: 3
  });//chosen

  $("#event_select").chosen({
    width: '50%'
   });//chosen

  function initialize() {
    var input = document.getElementById('location');
    new google.maps.places.Autocomplete(input);
  }

  function CompetitionInitialize() {
    var input = document.getElementById('competition_location');
    new google.maps.places.Autocomplete(input);
  }

  function EventbriteInitialize() {
    var input = document.getElementById('eventbrite_location');
    new google.maps.places.Autocomplete(input);
  }

  google.maps.event.addDomListener(window, 'load', initialize);
  google.maps.event.addDomListener(window, 'load', CompetitionInitialize);
  google.maps.event.addDomListener(window, 'load', EventbriteInitialize);

  //prevent form submit on enter key

  $(document).on('keypress','input',function(e){
     if(e.which == 13) {
       e.preventDefault();
     }
  })//keypress

//=============================Event brite import event functionality ============================
  // $(document).on('click','i#save_events_btn', function(event) {
  //       var event = {}
  //       event['name'] = $($(this).parent().parent('tr')[0]).children('td.name').text();
  //       event['description'] = $($(this).parent().parent('tr')[0]).children('td.description').text();
  //       event['start_date'] = $($(this).parent().parent('tr')[0]).children('td.start_date').text();
  //       event['end_date'] = $($(this).parent().parent('tr')[0]).children('td.end_date').text();
  //       event['start_time'] = $($(this).parent().parent('tr')[0]).children('td.start_time').text();
  //       event['end_time'] = $($(this).parent().parent('tr')[0]).children('td.end_time').text();
  //       event['end_time'] = $($(this).parent().parent('tr')[0]).children('td.end_time').text();
  //       event['host'] = gon.current_user_name;
  //       // event['location'] = $($(this).parent().parent('tr')[0]).children('td.location').text();
  //       // event['lat'] = $($(this).parent().parent('tr')[0]).children('td.lat').text();
  //       // event['lng'] = $($(this).parent().parent('tr')[0]).children('td.lng').text();
  //       event['image'] = $($(this).parent().parent('tr')[0]).children('td.image').text();
  //       var venue_id = $($(this).parent().parent('tr')[0]).children('td.venue_id').children('input').val();
  //       var category_id = $($(this).parent().parent('tr')[0]).children('td.category_id').children('input').val();     
  //       console.log('venue_id',venue_id);
  //       console.log('category_id',category_id);
  //       $.ajax({
  //         type: 'post',
  //         url: '/admin/eventbrite/get-category',
  //         data: {
  //           category_id: category_id,
  //           authenticity_token: gon.authenticity_token
  //         }
  //       }).done(function(p_resp){
         
  //         if(venue_id != '') {
  //           $.ajax({
  //             type: 'post',
  //             url: '/admin/eventbrite/get-venue',
  //             data: {
  //               venue_id: venue_id,
  //               authenticity_token: gon.authenticity_token
  //             },
  //             success: function(resp) {
  //               event['category'] = p_resp.data.category['name'];
  //               event['location'] = resp.data.venue['localized_address_display'];
  //               console.log('ajx',resp.data.venue['localized_address_display']);
  //               console.log('ajx_cat',p_resp);
  //             }
  //           });//ajax
  //         } 
  //       });//ajax
  //   console.log("event object",event);
  // });//click

  $(document).on('click','button.edit_events_btn', function(event) {
    var event = {}
    var get_venue_ajax = false;
    event['name'] = $($(this).parent().parent('tr')[0]).children('td.name').text();
    event['description'] = $($(this).parent().parent('tr')[0]).children('td.description').text();
    event['start_date'] = $($(this).parent().parent('tr')[0]).children('td.start_date').text();
    event['end_date'] = $($(this).parent().parent('tr')[0]).children('td.end_date').text();
    event['start_time'] = $($(this).parent().parent('tr')[0]).children('td.start_time').text();
    event['end_time'] = $($(this).parent().parent('tr')[0]).children('td.end_time').text();
    event['end_time'] = $($(this).parent().parent('tr')[0]).children('td.end_time').text();
    event['host'] = gon.current_user_name;
    // event['location'] = $($(this).parent().parent('tr')[0]).children('td.location').text();
    // event['lat'] = $($(this).parent().parent('tr')[0]).children('td.lat').text();
    // event['lng'] = $($(this).parent().parent('tr')[0]).children('td.lng').text();
    event['image'] = $($(this).parent().parent('tr')[0]).children('td.image').text();
    var venue_id = $($(this).parent().parent('tr')[0]).children('td.venue_id').children('input').val();
    var eventbrite_image = $($(this).parent().parent('tr')[0]).children('td.eventbrite_image').find('img').attr('src');
    var category_id = $($(this).parent().parent('tr')[0]).children('td.category_id').children('input').val();     
    console.log('venue_id',venue_id);
    console.log('category_id',category_id);
    $.ajax({
      type: 'post',
      url: '/admin/eventbrite/get-category',
      data: {
        category_id: category_id,
        authenticity_token: gon.authenticity_token
      }
    }).done(function(p_resp){
     
      if(venue_id != '') {
        $.ajax({
          type: 'post',
          url: '/admin/eventbrite/get-venue',
          data: {
            venue_id: venue_id,
            authenticity_token: gon.authenticity_token
          },
          success: function(resp) {
            get_venue_ajax = true;
            event['category'] = p_resp.data.category['name'];
            event['location'] = resp.data.venue['localized_address_display'];
            
            console.log('ajx',resp.data.venue['localized_address_display']);
            console.log('lat',resp.data.venue['latitude']);
            console.log('long', resp.data.venue['longitude']);
            console.log('location', resp.data.venue['localized_address_display']);
            console.log('eventbrite_image',eventbrite_image);
            console.log('ajx_cat',p_resp);
            $(".modal-body #eventbrite_image").val(eventbrite_image);
            $(".modal-body #name").val(event['name']);
            $(".modal-body #description").val(event['description']);
            $(".modal-body #start_date").val(event['start_date']);
            $(".modal-body #end_date").val(event['end_date']);
            $(".modal-body #start_time").val(event['start_time']);
            $(".modal-body #end_time").val(event['end_time']);
            $(".modal-body #lat").val(resp.data.venue['latitude']);
            $(".modal-body #lng").val(resp.data.venue['longitude']);
            $(".modal-body #eventbrite_location").val(resp.data.venue['localized_address_display']);
            $("#eventbrite_edit").modal('show');
          }
        });//ajax
      } 
    });//ajax
     
    if(get_venue_ajax == false) {
            $(".modal-body #eventbrite_image").val(eventbrite_image);
            $(".modal-body #name").val(event['name']);
            $(".modal-body #description").val(event['description']);
            $(".modal-body #start_date").val(event['start_date']);
            $(".modal-body #end_date").val(event['end_date']);
            $(".modal-body #start_time").val(event['start_time']);
            $(".modal-body #end_time").val(event['end_time']);
            $("#eventbrite_edit").modal('show');
    }

});//click

$(document).on('click','#eventbrite_save_btn', function(e){
  e.preventDefault();
  var validate = false;
  
  var form = $("form#eventbrite_import_form");
   if($('#categories_select').val() == null) {
      alert("Category shouldn't be empty");
      validate = false;
   }
   else {
    validate = true;
   }
   if($('#price_type').val() == 'pay_at_door' && $("#price").val() == '') {
    alert("Price is required.");
    validate = false;
   }
   else {
    validate = true;
   }

  $(form).find('input').each(function(index, value){
      console.log(value);
     if($(this).val() == '') {
      $(this).prepend( "<p>" + $(this).attr('class') + " is required.</p>" );
       $(this).css('border-color','red');
         validate = false;
     }
     else {
       $(this).css('border-color','transparent');
       validate = true;
     }
    });//each

   if(validate == true) {
     $("form#eventbrite_import_form").submit();
   }
})//click

$(document).on('submit','#eventbrite_import_form', function(event){
  event.preventDefault();
  var formData = new FormData(this);
  var url = "/admin/eventbrite/store-imported";
  $.ajax({
    url: url, 
    type: "POST",             
    data: formData, 
    contentType: false,        
    cache: false,           
    processData:false,       
    success: function(data) {
        console.log(data.success);
           if(data.success == true) {
             alert('Event imported successfully.');
           }
           else {
            alert('Event import failed.');
           
           }
           $("#eventbrite_edit").modal('hide');
          //location.reload();
      }  
    });//ajax
});//click

// import form validation
 
function validate_import_form() {
   var validate = false;
   var form = $("form#eventbrite_import_form");
   $(form).find('input').each(function(index, value){
      if($(this).hasClass('name') && $(this).val() == '') {
        $(this).css('border-color','red');
        validate = false;
        alert('Name is required.')
      }
      else {
        $(this).css('border-color','transparent');
        validate = true;
      }
     
      if($(this).hasClass('description') && $(this).val() == '') {
        $(this).css('border-color','red');
        validate = false;
      }
      else {
        $(this).css('border-color','transparent');
        validate = true;
      }

      if($(this).hasClass('start_date') && $(this).val() == '') {
        $(this).css('border-color','red');
        validate = false;
      }
      else {
        $(this).css('border-color','transparent');
        validate = true;
      }

      if($(this).hasClass('end_date') && $(this).val() == '') {
        $(this).css('border-color','red');
        validate = false;
      }
      else {
        $(this).css('border-color','transparent');
        validate = true;
      }

      if($(this).hasClass('start_Time') && $(this).val() == '') {
        $(this).css('border-color','red');
        validate = false;
      }
      else {
        $(this).css('border-color','transparent');
        validate = true;
      }

      if($(this).hasClass('end_time') && $(this).val() == '') {
        $(this).css('border-color','red');
        validate = false;
      }
      else {
        $(this).css('border-color','transparent');
        validate = true;
      }
     
   });//each
  
}

//phone number validation

function phonenumber(inputtxt) {
  var phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
  if(inputtxt.value.match(phoneno)) {
    return true;
  }
  else {
    alert("message");
    return false;
  }
}

});//ready