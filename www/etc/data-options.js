
$("#dataset-menu").menu();
// $("#showOriginal").prop("disabled", true);
// $('#showOriginal-holder').find('.bootstrap-switch-id-showOriginal').removeClass('bootstrap-switch-disabled')
$("#output-holder").addClass("hidden"); 
//if ((navigator.userAgent.indexOf("MSIE") != -1) && (navigator.userAgent.indexOf("Edge") != -1)) {SimpleBar_init("#shownColumns")};
SimpleBar_init("#shownColumns");
// $("#shownColumns").width(188);

// $('#show-hide-columns').mouseover(() => {
//     w = Math.max(...$("#dataOptions .awesome-checkbox label").map(function(){return $(this).width();}).get());
//     console.log(w);
//     $("#shownColumns").width(w + 188);
// });

// $("#dataOptions .awesome-checkbox label").ready(function(){
//     // console.log('loaded');
//     w = Math.max(...$("#dataOptions .awesome-checkbox label").map(function(){return $(this).width();}).get());
//     //$("#dataOptions .ui-widget.ui-widget-content").width(w);
//     console.log($("#dataOptions .awesome-checkbox label").map(function(){return $(this).width();}).get());
//     console.log(w);
//     $("#shownColumns").width(w + 188);
// });


//  $("#shownColumns").css('width','fit-content');

$('#dataOptions .awesome-checkbox').click(function(e){
    if (!$(this).find('input').is(e.target) && !$(this).find('label').is(e.target)) $(this).find('input').click();
});

let last_default = null;
$('#dataOptions .awesome-checkbox').contextmenu(function(e){
    e.preventDefault();
    console.log($(this).find('label').html());
    Shiny.onInputChange('idCol', $(this).find('label').html());
    $(this).find('label').toggleClass('defaultID');
    $(last_default).toggleClass('defaultID');
    last_default = $(this).find('label');
    // if (!$(this).find('input').is(e.target) && !$(this).find('label').is(e.target)) $(this).find('input').click();
});

$('#columns-chooser-holder').mouseup(function(){
    $('#show-hide-columns').trigger('mouseover');
    $('#show-hide-columns').trigger('click');
})

// $('#show-hide-columns').on('mouseover', function(){
//     w = Math.max(...$("#dataOptions .awesome-checkbox label").map(function(){return $(this).width();}).get());
//     //$("#dataOptions .ui-widget.ui-widget-content").width(w);
//     // console.log($("#dataOptions .awesome-checkbox label").map(function(){return $(this).width();}).get());
//     // console.log(w);
//     $("#shownColumns").width(w+188);
// })

// $('#dataOptions .awesome-checkbox').on('click','label', function(){$(this).find('input').click();});

tippy(document.querySelectorAll('#dataOptions .awesome-checkbox'),{
    content: "<span style='font-size: 12.5px'>Right click to set ID column.</span>",
    theme: "light-border",
    size: 'large',
    touch: true,
    placement: 'top-start',
    interactive: true,
    duration: 500}
);

$('#dataOptions .awesome-checbox').on('click','.tippy-content', function(e){
    console.log($(this));
    $(this).trigger('contextmenu');
})