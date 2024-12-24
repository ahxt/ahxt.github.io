// Xuning Yang 2021
// function handling for gifs: hover display on the side for desktop, click to display sequentially for mobile

var giflinks = document.getElementsByClassName("gif-link");
var i;

for (i = 0; i < giflinks.length; i++) {
 giflinks[i].addEventListener("click", function() {
   this.classList.toggle("active");
   // only do collapsible content if the page is narrower than 1300px
   if ($(window).width() < 1300) {
     var content = document.getElementById(this.id+"-gif")
     if (content.style.display === "block") {
       content.style.display = "none";
       content.style.textAlign.default = "true";
       content.style.marginLeft.default = "true";
       content.style.marginRight.default= "true";
       content.style.position.default = "true";
       content.style.marginTop.default = "true";
       content.style.marginBottom.default = "true";
     } else {
       content.style.display = "block";
       content.style.marginTop = "10px";
       content.style.marginBottom = "10px";
       content.style.textAlign = "center";
       content.style.position = "static";
     }
   }
 });

// for page wider than 1300px do mouseover on the side
 giflinks[i].addEventListener("mouseover", function() {
   if ($(window).width() > 1300) {
     var content = document.getElementById(this.id+"-gif")
     content.style.display = "block";
     content.style.position = "absolute";
     content.style.right = "110%";
     content.style.bottom = "-2em";

   }
 });

 giflinks[i].addEventListener("mouseout", function() {
   if ($(window).width() > 1300) {
     var content = document.getElementById(this.id+"-gif")
     content.style.display = "none";
     content.style.position.default = "true";
     content.style.right.default = "true";
     content.style.bottom.default = "true";
   }
 });
}
