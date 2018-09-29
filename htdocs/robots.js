$(function () {
  var loader = (function () {
    verbs = [
      'writing',
      'crafting',
      'authoring',
      'assembling',
      'compiling',
    ];
    nouns = [
      'plot twists',
      'character biographies',
      'suspenseful passages',
      'exposition',
      'character monologues',
      'action scenes',
      'narration'
    ];
    return function () {
      v = verbs[parseInt(Math.random() * verbs.length)];
      n = nouns[parseInt(Math.random() * nouns.length)];
      return v + ' ' + n + '...';
    }
  })();
  window.setInterval(function () {
    $('#loading span').fadeOut({
      complete: function () {
        $('#loading span').text(loader()).fadeIn();
      }
    });
  }, 2400);

  var delay = function (n, fn) {
    window.setTimeout(fn, n * 1000);
  };

  $(document.body)
    .on('click', '.s1 button', function (event) {
      event.preventDefault();
      var who = $(event.target).text();

      $('.s2').show();
      $('.s1').hide();
      delay(4, function () {
        $.ajax({
          type: 'GET',
          url:  '/story/'+$(event.target).data('style'),
          success: function (data) {
            $('.s3 h1').text(data.title);
            $('.s3 span.style em').text(who);
            $('.s3 .text').html(data.text);

            $('.s2').hide();
            $('.s3').show();
          },
          error: function (xhr) {
            // FIXME
          }
        });
      });
    })
  ;
})
