/* var declaration */

let cssVar = new CSSGlobalVariables();
let barSize = {barLeft: 0, barRight: 'auto'};

set_bar = (x, y) => {
    barSize.barLeft = x;
    barSize.barRight = y;
    cssVar.barLeft = barSize.barLeft + 'px';
    cssVar.barRight = `calc(100% - ${barSize.barRight}px)`;
};

/* jquery code run */

$(document).ready(() => {
    $('#grand-top-bar').addClass('pseudo-hidden');
    $('.navbar-toggle').addClass('hidden');
    set_bar($('#grand-top-bar li.active').position().left, $('#grand-top-bar li.active').position().left + $('#grand-top-bar li.active').outerWidth());
    
    $('#grand-top-bar').find('li').hover(function(){
        if ($(this).position().left > barSize.barLeft)
            set_bar(barSize.barLeft, $(this).position().left + $(this).outerWidth());
        else
            set_bar($(this).position().left, barSize.barRight);
        setTimeout(set_bar, 200, $(this).position().left, $(this).position().left + $(this).outerWidth());
    }, function(){
        setTimeout(set_bar, 200, $('#grand-top-bar li.active').position().left, $(`#grand-top-bar li.active`).position().left + $('#grand-top-bar li.active').outerWidth());
    });

    $('#grand-top-bar').find('li a').on('click', function(){
        set_bar($(this).parent().position().left, $(this).parent().position().left + $(this).parent().outerWidth());
    });

    $("#datasource").on("change", function() {
        $('#overlay').fadeIn(1000);
        $('#grand-top-bar').removeClass('pseudo-hidden');
        $('.navbar-toggle').removeClass('hidden');
        if ($('#datasource').val() == ''){
            $('#sidebar-holder').hide();
            $('#data-input-holder').addClass('center', 300);
            $($('#data-input-holder label')[0]).removeClass('hidden');
            $('#overlay .lds-roller').addClass('hidden',1000);
        } else {
            $('#overlay .lds-roller').removeClass('hidden',1000);
            $('#data-input-holder').removeClass('center', 1000);
            $($('#data-input-holder label')[0]).addClass('hidden', 1000);
            $('#datasource_progress div').html('');
        }
    });
});

/* swipe event */

$(window).on('swipeleft', () => {
    idx = 0;
	document.querySelectorAll('#grand-top-bar li').forEach(function(item, index){
    	if ($(item).hasClass('active')) {
			idx = index;
         }
	});

    if(document.querySelectorAll('#grand-top-bar li a')[idx + 1]) 
        $($('#grand-top-bar').find('li a')[idx + 1]).click(); 
    else $($('#grand-top-bar').find('li a')[0]).click();
});

$(window).on('swiperight', () => {
    idx = 0;
	document.querySelectorAll('#grand-top-bar li').forEach(function(item, index){
    	if ($(item).hasClass('active')) {
			idx = index;
         }
	});

    if(document.querySelectorAll('#grand-top-bar li a')[idx - 1]) 
        $($('#grand-top-bar').find('li a')[idx - 1]).click(); 
    else $($('#grand-top-bar').find('li a')[$('#grand-top-bar').find('li a').length - 1]).click();
});

/* resize event */
$(window).resize(() => {
    set_bar($('#grand-top-bar li.active').position().left, $('#grand-top-bar li.active').position().left + $('#grand-top-bar li.active').outerWidth());
})

/* R listener */