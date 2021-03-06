(function($) {
  $(Screw).bind("before", function(){
    $('.it')
      .bind('passed', function(){
        java.lang.System.out.print(".");

        BlueRidge.CommandLine.passed++;
      })
      .bind('failed', function(e, reason){
        java.lang.System.out.print("F");

        BlueRidge.CommandLine.failed++;

        BlueRidge.CommandLine.messages.push(BlueRidge.CommandLine.exampleName(this)
                                + '\n'
                                + reason
                                + '\n'
                                + 'in ' + BlueRidge.CommandLine.specFile
                                + '\n'
                                + (reason.rhinoException ? reason.rhinoException.scriptStackTrace + "\n" : "")
        );
      });
  });
})(jQuery);
