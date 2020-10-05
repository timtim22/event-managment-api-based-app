$(document).ready(function(){
  var autocomplete;
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
        var validated = false;
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


//user is "finished typing," do something

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

 
 $(document).on('click','.free_ticket', function(event){
  $('input.price_type').val('free');
  $(".pay_at_door_input").remove();
  $(".paid_ticket_input").remove();
    $('.input_section').show();
    var inputs = '<br><div class="form-group free_ticket_input input">' 
        + '<label style="margin-right: 30px; " class="free_ticket_input">Ticket Name </label>'
        + '<input type="text" name="free_ticket[title]" style="margin-right: 30px;" class="free_ticket_input input">'
        + '<label style="margin-right: 30px;" class="free_ticket_input">Quantity</label>'
        + '<input type="number" name="free_ticket[quantity]" style="margin-right: 30px;" class="free_ticket_input input">'
        + '<label style="margin-right: 30px;" class="free_ticket_input">Max Per Order</label>'
        + '<input type="number" name="free_ticket[per_head]" style="margin-right: 30px;" class="free_ticket_input input">'
        + '</div>';
    $('.input_section').append(inputs);
  })//click

  $(document).on('click','.paid_ticket', function(event){
    $('input.price_type').val('buy');
    $(".free_ticket_input").remove();
    $(".pay_at_door_input").remove();
    $('.input_section').show();
    var inputs = '<br><div class="form-group paid_ticket_input">' 
        + '<label style="margin-right: 30px;">Ticket Name </label><br>'
        + '<input type="text" name="paid_ticket[title][]" class="input" style="margin-right: 30px;">'
        + '</div>'
        + '<div class="form-group paid_ticket_input" >'
        + '<label style="margin-right: 30px;">Quantity</label><br>'
        + '<input type="number" name="paid_ticket[quantity][]" class="input" style="margin-right: 30px;">'
        + '</div>'
        + '<div class="form-group paid_ticket_input" >'
        + '<label style="margin-right: 30px;">Price</label><br>'
        + '<input type="number" name="paid_ticket[price][]" class="input" style="margin-right: 30px;">'
        + '</div>'
        + '<div class="form-group paid_ticket_input" >'
        + '<label style="margin-right: 30px;">Max Per Order</label><br>'
        + '<input type="number" name="paid_ticket[per_head][]" class="input" style="margin-right: 30px;">'
        + '</div>';
    $('.input_section').append(inputs);
  })//click


  $(document).on('click','.pass', function(event){
    $('.input_section').show();
    var inputs = '<br><div class="form-group pass_input">' 
        + '<label style="margin-right: 30px;">Pass Name </label><br>'
        + '<input type="text" name="pass[title][]" class="input" style="margin-right: 30px;">'
        + '</div>'
        + '<div class="form-group pass_input"> '
        + '<label style="margin-right: 30px;">Description</label><br>'
        + '<textarea name="pass[description][]" class="input" style="margin-right: 30px;"></textarea>'
        + '</div>'
        + '<div class="form-group pass_input"> '
        + '<label style="margin-right: 30px;">Quantity</label><br>'
        + '<input type="number" name="pass[quantity][]" class="input" style="margin-right: 30px;">'
        + '</div>'
        + '<div class="form-group pass_input" >'
        + '<label style="margin-right: 30px;">Reward Per Redeem</label><br>'
        + '<input type="number" name="pass[ambassador_rate][]" class="input" style="margin-right: 30px;">'
        + '</div>'
        + '<div class="form-group pass_input"> '
        + '<label style="margin-right: 30px;">Valid from</label><br>'
        + '<input type="text"  name="pass[valid_from][]" value="2020-12-12" class="input date" style="margin-right: 30px;">'
        + '</div>'
        + '<div class="form-group pass_input"> '
        + '<label style="margin-right: 30px;">Valid to</label><br>'
        + '<input type="text" name="pass[valid_to][]" class="input date" value="2020-12-12" style="margin-right: 30px;">'
        + '</div>';
    $('.input_section').append(inputs);
  })//click


  $(document).on('click','.pay_at_door', function(event){
    $('input.price_type').val('pay_at_door');
    $(".free_ticket_input").remove();
    $(".paid_ticket_input").remove();
    $('.input_section').show();
    var inputs = '<br><div class="form-group pay_at_door_input">' 
        + '<label style="margin-right: 30px;">Start Price</label>'
        + '<input type="number" name="pay_at_door[start_price]" class="input" style="margin-right: 30px;">'
        + '<label style="margin-right: 30px;">Quantity</label>'
        + '<input type="number" name="pay_at_door[end_price]" class="input" style="margin-right: 30px;">'
        + '</div>';
    $('.input_section').append(inputs);
  })//click


$(document).on('click','#price_range_checkbox', function(event){
  if ($('#price_range_checkbox').is(':checked') == true) {
    $('#price_range_div').show();
    $('#single_price').hide();
 }
 else {
   $('#price_range_div').hide();
   $('#single_price').show();
 }
})//click

$(document).on('change','#price_type',function(e){
  setSelectValue();

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
    autocomplete = new google.maps.places.Autocomplete(input, { types: ['geocode'] });
    autocomplete.setFields(["place_id", "geometry"]);
    // When the user selects an address from the drop-down, populate the
    // address fields in the form.
    autocomplete.addListener('place_changed', fillInLatLng);
       
  } 


  function fillInLatLng() {
     var lat = autocomplete.getPlace().geometry.location.lat(); 
     var lng = autocomplete.getPlace().geometry.location.lng(); 

     $('input#lat').val(lat);
     $('input#lng').val(lng);      
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
            
            // console.log('ajx',resp.data.venue['localized_address_display']);
            // console.log('lat',resp.data.venue['latitude']);
            // console.log('long', resp.data.venue['longitude']);
            // console.log('location', resp.data.venue['localized_address_display']);
            // console.log('eventbrite_image',eventbrite_image);
            // console.log('ajx_cat',p_resp);
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

// send reset password email
$(document).on('click','#send_reset_email', function(event){
  event.preventDefault();
  var url = "/admin/send-reset-email";
  $.ajax({
    url: url, 
    type: "POST",             
    data: {
      authenticity_token: gon.authenticity_token,
      email: $('#email').val()
    },   
    success: function(data) {
      if(data.code ==  200) {
        $(".email_success").show();
        $(".email_danger").hide();
        $(".email_success").html(data.message);
      }
       else if(data.code == 400){
        $(".email_danger").show();
        $(".email_success").hide();
       $(".email_danger").html(data.message);
       }
      }  
    });//ajax
});//click

$(document).on('click','#reset_password', function(event){
  event.preventDefault();
  var form = $("#reset_password_form");
  $(form).submit();
});//click

// reset password 
$(document).on('submit','#reset_password_form', function(event){
  event.preventDefault();
  var formData = new FormData(this);
  var url = "/admin/reset-password";
  $.ajax({
    url: url, 
    type: "POST",             
    data: formData, 
    contentType: false,        
    cache: false,           
    processData:false,       
    success: function(data) {
      if(data.code ==  200) {
        $(".email_success").show();
        $(".email_danger").hide();
        $(".email_success").html(data.message + ' <a href="/admin/session/new">Please login now</a>');
      }
       else if(data.code == 400){
        $(".email_danger").show();
        $(".email_success").hide();
       $(".email_danger").html(data.message);
       }
       
      }  
    });//ajax
});//click


});//ready