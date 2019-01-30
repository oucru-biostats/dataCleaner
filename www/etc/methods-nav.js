responsiveMethodsNav = () => {
    
    $('#methodsNav ul li a').removeClass('collapsed');
    $('#methodsNav ul').css('margin-left','0');
    $('#methodsToggle').css('margin-left','0');

    if ($(window).width() <= 500){
        $('#methodsNav ul li a').click(function(){
            $('#methodsNav ul').css('margin-left','-90vw');
            $('#methodsToggle').css('margin-left','-90vw');
        });
        
        $('#methodsNav').on('swiperight', function(){
            $('#methodsNav ul').css('margin-left','0');
            $('#methodsToggle').css('margin-left','0');
        });
    } else if ($(window).width() < 768){
        $('#methodsNav ul li a').click(function(){
            if ($('#methodsNav ul').css('margin-left') == '0px'){
                $(this).addClass('collapsed');
                $('#methodsNav ul').css('margin-left','-200px');
                $('#methodsToggle').css('margin-left','-200px');
            } else {
                $(this).removeClass('collapsed');
                $('#methodsNav ul').css('margin-left','0');
                $('#methodsToggle').css('margin-left','0');
            }
        });

        $('#methodsNav .col-sm-9').mousedown(() => {
            if ($('#methodsNav ul').css('margin-left') == '0px'){
                $('#methodsNav ul li a').addClass('collapsed');
                $('#methodsNav ul').css('margin-left','-200px');
                $('#methodsToggle').css('margin-left','-200px');
            } 
        });
        
        $('#methodsNav').on('swiperight', function(){
            $('#methodsNav ul li a').removeClass('collapsed');
            $('#methodsNav ul').css('margin-left','0');
            $('#methodsToggle').css('margin-left','0');
        });
    } else {
        $('#methodsNav ul').css('margin-left',0);
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

