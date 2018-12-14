document.querySelector("#mojobar-brand").addEventListener("click", function (e) {
  if (window.innerWidth > 900) return;
  e.preventDefault();
  document.querySelector("#mojobar").classList.toggle("open");
});
