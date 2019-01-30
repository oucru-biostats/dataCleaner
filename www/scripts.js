/* var declaration */

let cssVar = new CSSGlobalVariables();
let barSize = {barLeft: 0, barRight: 'auto'};
let nav_title = {
    long_form: ['Missing Data','Numerical Outliers','Cartegorical Loners','Binaries','Whitespaces','Spelling Issues', 'Duplicated IDs'],
    short_form: ['MSD','OUTL','LNR','BIN','WSP','SPL','DID']
}

set_bar = (x, y) => {
    barSize.barLeft = x;
    barSize.barRight = y;
    cssVar.barLeft = barSize.barLeft + 'px';
    cssVar.barRight = `calc(100% - ${barSize.barRight}px)`;
};

set_inputDT = function(table){
    table.cells().every(function(i, j, tab, cell) {
        var $this = $(this.node());
        if ($this.find('input').length > 0){
          $this.find('input').addClass('form-control');
        }
      });
}

tagParse = function(table){
    table.cells().every(function(i, j, tab, cell){
        var $this = $(this.node());
        tagList = ['wrong','corrected', 'navalue', 'loner'];
        for (i = 0; i < tagList.length; i++) {
            tag = tagList[i];
            
            if ($this.find(tag).length > 0){
                content = $this.find(tag).html();
                $this.html(content);
                $this.addClass(tag + '-data');
            }
        }
    });
};

SimpleBar_init = (elList) => {
    $(document).find(elList).each(function(idx, el) {
        new SimpleBar(el);
        $(el).css('overflow','unset');
    });
}

responsiveText = function(){
    cssVar.grandTabTop = ($('#dataset').position().top + $('#dataset').outerHeight()) + 'px';
    if ($(window).width() < 768){
        // $('#methodsNav').addClass('smallMedia', 300);
        // $('#methodsToggle').addClass('smallMedia', 300);
        // $('#methodsNav').find('a').map((idx, a) => $(a).html(nav_title.short_form[idx]));
        $('.paginate_button.previous').html('◄');
        $('.paginate_button.next').html('►');
    } else {
        // $('#methodsNav').removeClass('smallMedia', 300);
        // $('#methodsToggle').removeClass('smallMedia', 200);
        // $('#methodsNav').find('a').map((idx, a) => $(a).html(nav_title.long_form[idx]));
        $('.paginate_button.previous').html('Previous');
        $('.paginate_button.next').html('Next');
    }    
}

_init_methodsSection = () => {
    // if ($(window).width() < 768){
    //     $('#methodsNav').addClass('smallMedia', 300);
    //     $('#methodsToggle').addClass('smallMedia', 300);
    //     $('#methodsNav').find('a').map((idx, a) => $(a).html(nav_title.short_form[idx]));
    // } else {
    //     $('#methodsNav').removeClass('smallMedia', 300);
    //     $('#methodsToggle').removeClass('smallMedia', 300);
    //     $('#methodsNav').find('a').map((idx, a) => $(a).html(nav_title.long_form[idx]));
    // }   
}

_DT_callback = function(dt) {
    SimpleBar_init('#dataset .dataTables_scrollBody');
    set_inputDT(dt.api().table()); 
    tagParse(dt.api().table());

    /* Send AJAX to R */
    $('#dataset .dataTables_scrollHeadInner thead th').contextmenu(function(e){
        e.preventDefault();
        $('#dataset .dataTables_scrollHeadInner thead th').css('color', '#000');
        $(e.currentTarget).css('color','var(--color-active)');
        console.log($(this).html());
        Shiny.onInputChange('key', e.currentTarget.innerHTML);
    });

    $('#dataset .dataTables_scrollHeadInner thead th').on('taphold', function(e){
        e.preventDefault();
        $('#dataset .dataTables_scrollHeadInner thead th').css('color', '#000');
        $(e.currentTarget).css('color','var(--color-active)');
        console.log($(this).html());
        Shiny.onInputChange('key', e.currentTarget.innerHTML);
    });

    responsiveText();
}

_DT_initComplete = function() {
    
    // SimpleBar_init('#dataset .dataTables_scroll');
    
    $('#dataset .dataTables_scroll .simplebar-content').scroll(function(){
    let left = $('#dataset .dataTables_scrollBody .simplebar-content').scrollLeft();
    $('#dataset .dataTables_scrollHead').animate({
        scrollLeft: left}, 5);
    });
    SimpleBar_init('#methodsNav .tab-pane');

    $('#overlay').fadeOut(1000);
    $('#sidebar-holder').show();
    
    tippy('.res-log td', {
        theme: 'light-border',
        size: 'large',
        touch: true,
        placement: 'top-start',
        duration: 500,
        interactive: true,
        trigger: 'click'
    });

    _init_methodsSection();
}

/* jquery code run */

$(document).ready(() => {
    cssVar.datasetTop = $(window).width() > 500 ? '70px' : '120px';
    $('#grand-top-bar').addClass('pseudo-hidden');
    $('.navbar-toggle').addClass('hidden');
    set_bar($('#grand-top-bar li.active').position().left, $('#grand-top-bar li.active').position().left + $('#grand-top-bar li.active').outerWidth());
    
    $('#grand-top-bar').find('li').hover(function(){
        if ($(this).position().left > barSize.barLeft)
            set_bar(barSize.barLeft, $(this).position().left + $(this).outerWidth());
        else
            set_bar($(this).position().left, barSize.barRight);
        setTimeout(set_bar, 150, $(this).position().left, $(this).position().left + $(this).outerWidth());
    }, function(){
        setTimeout(set_bar, 150, $('#grand-top-bar li.active').position().left, $(`#grand-top-bar li.active`).position().left + $('#grand-top-bar li.active').outerWidth());
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

    $('#data-input input:text').click(function(){
        $($(this).parent()).find('label.input-group-btn').click();
    });
});

/* swipe event */

$('nav').on('swipeleft', (event) => {
    console.log(event);
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

$('nav').on('swiperight', () => {
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
    cssVar.datasetTop = $(window).width() > 500 ? '70px' : '120px';

    responsiveText();  
})

/* R listener */
Shiny.addCustomMessageHandler("excel", function(isTRUE){
    if(isTRUE) {
        $('#sheet-input').removeClass('pseudo-hidden',300);
        $("#data-input-holder #data-input").removeClass('fullWidth', 300);
    } else {
        $('#sheet-input').addClass('pseudo-hidden',300);
        $("#data-input-holder #data-input").addClass('fullWidth', 300);
    }
});

Shiny.addCustomMessageHandler('changeSheet', function(empty){
    $('#overlay').fadeIn(1000);
    $('#overlay .lds-roller').removeClass('hidden', 1000);
});

//<div>Icons made by <a href="https://www.flaticon.com/authors/google" title="Google">Google</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>