let cssVar = new CSSGlobalVariables();
let barSize = {barLeft: 0, barRight: 'auto'};

set_bar = (x, y) => {
    barSize.barLeft = x;
    barSize.barRight = y;
    cssVar.barLeft = barSize.barLeft + 'px';
    cssVar.barRight = `calc(100% - ${barSize.barRight}px)`;
}

$(document).ready(() => {
    set_bar($('#grand-top-bar li.active').position().left, $('#grand-top-bar li.active').position().left + $('#grand-top-bar li.active').outerWidth());
    
    $('#grand-top-bar').find('li').hover(function(){
            if ($(this).position().left > barSize.barLeft)
                set_bar(barSize.barLeft, $(this).position().left + $(this).outerWidth());
            else
                set_bar($(this).position().left, barSize.barRight);
            setTimeout(set_bar, 200, $(this).position().left, $(this).position().left + $(this).outerWidth());
    }, () => {
            setTimeout(set_bar, 200, $('#grand-top-bar li.active').position().left, $(`#grand-top-bar li.active`).position().left + $('#grand-top-bar li.active').outerWidth());
        
    });

    $('#grand-top-bar').find('li a').on('click', function(){
        set_bar($(this).offset().left, $(this).offset().left + $(this).outerWidth());
    })
})




$(window).on('swiperight', () => {
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

$(window).on('swipeleft', () => {
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