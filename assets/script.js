(() => {
  const rafScroll = (fn) => {
    let id = null;
    const run = () => { id = null; fn(); };
    addEventListener("scroll", () => { if (id == null) id = requestAnimationFrame(run); }, { passive: true });
    return () => { if (id == null) id = requestAnimationFrame(run); };
  };

  const codes = document.querySelectorAll("pre code");
  codes.forEach((c) => {
    if (c.dataset.lang) c.classList.add("language-" + c.dataset.lang);
  });
  addEventListener("load", () => {
    if (!window.hljs) return;
    codes.forEach((el) => {
      if (el.dataset.hlDone) return;
      try { hljs.highlightElement(el); } catch {}
      el.dataset.hlDone = "1";
    });
  });

  document.querySelectorAll('a[href^="http"]').forEach((a) => {
    a.target = "_blank";
    a.rel = "noopener";
  });

  const aside = document.querySelector(".article__toc");

  const btn = document.querySelector(".to-top");
  if (btn) {
    const show = () => btn.classList.toggle("is-visible", scrollY > 400);
    rafScroll(show);
    btn.addEventListener("click", () => scrollTo({ top: 0, behavior: "smooth" }));
    show();
  }

  document.querySelectorAll(".prose pre").forEach((pre) => {
    if (pre.querySelector(".code-copy")) return;
    const b = document.createElement("button");
    b.type = "button";
    b.className = "code-copy";
    b.textContent = "Copy";
    b.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText((pre.querySelector("code") || pre).innerText);
        b.textContent = "Copied";
      } catch { b.textContent = "Failed"; }
      setTimeout(() => (b.textContent = "Copy"), 1200);
    });
    pre.appendChild(b);
  });

  if (!aside) return;
  const links = [...aside.querySelectorAll('a[href^="#"]')];
  if (!links.length) return;
  const entries = links.map((a) => [
    document.getElementById(decodeURIComponent(a.getAttribute("href").slice(1))), a,
  ]).filter(([h]) => h).sort((x, y) => x[0].offsetTop - y[0].offsetTop);
  if (!entries.length) return;

  let active = null;
  const move = (link) => {
    const ar = aside.getBoundingClientRect(), lr = link.getBoundingClientRect();
    aside.style.setProperty("--toc-marker-y", lr.top - ar.top + lr.height / 2 + aside.scrollTop + "px");
    aside.style.setProperty("--toc-marker-x", lr.left - ar.left + aside.scrollLeft + "px");
    aside.classList.add("has-active-marker");
    if (aside.scrollHeight > aside.clientHeight) {
      const delta = lr.top - (ar.top + aside.clientHeight * 0.25);
      if (Math.abs(delta) > 2) aside.scrollTo({ top: aside.scrollTop + delta, behavior: "smooth" });
    }
  };
  const update = () => {
    const y = scrollY + 80;
    let next = entries[0];
    for (const entry of entries) {
      if (entry[0].offsetTop <= y) next = entry;
      else break;
    }
    if (next === active) return;
    active = next;
    links.forEach((a) => a.removeAttribute("aria-current"));
    active[1].setAttribute("aria-current", "location");
    move(active[1]);
  };
  const onScroll = rafScroll(update);
  addEventListener("resize", onScroll, { passive: true });
  document.fonts?.ready?.then(() => { if (active) move(active[1]); });
  update();
})();
