responsiveMethodsNav = () => {
    $('#methodsNav ul').removeClass('collapsed');
    $('#methodsToggle').removeClass('collapsed');
    cssVar.contentHeight = $('#methodsNav .tab-pane.active').height() + 'px';

    if ($(window).width() <= 500){
        $('#methodsNav ul li a').click(function(){
            cssVar.contentHeight = $('#methodsNav .tab-pane.active').height() + 'px';
            $('#methodsNav ul').toggleClass('collapsed');
            $('#methodsToggle').toggleClass('collapsed');
        });
        
        $('#methodsNav').on('swiperight', function(){
            $('#methodsNav ul').removeClass('collapsed');
            $('#methodsToggle').removeClass('collapsed');
        });
    } else if ($(window).width() < 768){
        $('#methodsNav ul li a').click(function(){
            $('#methodsNav ul').toggleClass('collapsed');
            $('#methodsToggle').toggleClass('collapsed');
        });

        $('#methodsNav .col-sm-9').mousedown(() => {
            if (!$('#methodsNav ul').hasClass('collapsed')){
                cssVar.contentHeight = $('#methodsNav .tab-pane.active').height() + 'px';
                $('#methodsNav ul').addClass('collapsed');
                $('#methodsToggle').addClass('collapsed');
            }
        });
        
        $('#methodsNav').on('swiperight', function(){
            cssVar.contentHeight = $('#methodsNav .tab-pane.active').height() + 'px';
            $('#methodsNav ul').removeClass('collapsed');
            $('#methodsToggle').removeClass('collapsed');
        });
    } else {
        $('#methodsNav ul').removeClass('collapsed');
        $('#methodsNav ul li a').off('click');
        $('#methodsNav').off('swiperight');
    }
}

$('#methodsNav div.col-sm-4.well')
.removeClass('col-sm-4')
.addClass('col-sm-3')
.parent().find('div.col-sm-8').removeClass('col-sm-8').addClass('col-sm-9');



responsiveMethodsNav();
$(window).resize(() => {
    responsiveMethodsNav();
});

