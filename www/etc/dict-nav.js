responsiveDictNav = () => {
    $('#dictNav ul').removeClass('collapsed');
    cssVar.contentHeight = $('#dictNav .tab-pane.active').height() + 'px';

    if ($(window).width() <= 500){
        $('#dictNav ul li a').click(function(){
            cssVar.contentHeight = $('#dictNav .tab-pane.active').height() + 'px';
            $('#dictNav ul').toggleClass('collapsed');
        });
        
        $('#dictNav').on('swiperight', function(){
            $('#dictNav ul').removeClass('collapsed');
        });
    } else if ($(window).width() < 768){
        $('#dictNav ul li a').click(function(){
            $('#dictNav ul').toggleClass('collapsed');
        });

        $('#dictNav .col-sm-9').mousedown(() => {
            if (!$('#dictNav ul').hasClass('collapsed')){
                cssVar.contentHeight = $('#dictNav .tab-pane.active').height() + 'px';
                $('#dictNav ul').addClass('collapsed');
            }
        });
        
        $('#dictNav').on('swiperight', function(){
            cssVar.contentHeight = $('#dictNav .tab-pane.active').height() + 'px';
            $('#dictNav ul').removeClass('collapsed');
        });
    } else {
        $('#dictNav ul').removeClass('collapsed');
        $('#dictNav ul li a').off('click');
        $('#dictNav').off('swiperight');
    }
}



responsiveDictNav();

$(window).resize(() => {
    responsiveDictNav();
});
