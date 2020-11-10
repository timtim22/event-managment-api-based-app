var stripe = Stripe('pk_test_cx54ILItLp0Zv9hEpA34R8Gl', {
  stripeAccount: '{{acct_1Gd8gkKAlj9ePs8J}}'
});

var style = {
  base: {
    color: "#32325d",
  }
};

var card = elements.create("card", { style: style });
card.mount("#card-element");

cardElement.addEventListener('change', function(event) {
  var displayError = document.getElementById('card-errors');
  if (event.error) {
    displayError.textContent = event.error.message;
  } else {
    displayError.textContent = '';
  }
});