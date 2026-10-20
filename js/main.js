/**
 * Peter Aufner - Static Website JavaScript
 * Handles mobile menu, smooth scrolling, and other interactions
 */

(function () {
    "use strict";

    // ===================================
    // Mobile Menu Toggle
    // ===================================
    const menuBtn = document.querySelector(".header__menu-btn");
    const mobileNav = document.querySelector(".header__mobile-nav");

    if (menuBtn && mobileNav) {
        menuBtn.addEventListener("click", function () {
            const isExpanded = this.getAttribute("aria-expanded") === "true";
            this.setAttribute("aria-expanded", !isExpanded);
            mobileNav.classList.toggle("is-open");
        });

        // Close mobile menu when clicking a link
        const mobileLinks = mobileNav.querySelectorAll(".header__mobile-nav-link");
        mobileLinks.forEach(function (link) {
            link.addEventListener("click", function () {
                menuBtn.setAttribute("aria-expanded", "false");
                mobileNav.classList.remove("is-open");
            });
        });

        // Close mobile menu on escape key
        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape" && mobileNav.classList.contains("is-open")) {
                menuBtn.setAttribute("aria-expanded", "false");
                mobileNav.classList.remove("is-open");
                menuBtn.focus();
            }
        });
    }

    // ===================================
    // Smooth Scrolling for Anchor Links
    // ===================================
    const anchorLinks = document.querySelectorAll('a[href^="#"]');

    anchorLinks.forEach(function (link) {
        link.addEventListener("click", function (e) {
            const href = this.getAttribute("href");

            // Skip if it's just "#" or empty
            if (href === "#" || href === "") {
                return;
            }

            const target = document.querySelector(href);

            if (target) {
                e.preventDefault();

                // Get header height for offset
                const header = document.querySelector(".header");
                const headerHeight = header ? header.offsetHeight : 0;

                // Calculate scroll position
                const targetPosition =
                    target.getBoundingClientRect().top + window.pageYOffset - headerHeight;

                // Smooth scroll to target
                window.scrollTo({
                    top: targetPosition,
                    behavior: "smooth",
                });

                // Update URL without triggering scroll
                history.pushState(null, null, href);

                // Focus the target for accessibility
                target.setAttribute("tabindex", "-1");
                target.focus({ preventScroll: true });
            }
        });
    });

    // ===================================
    // Active Navigation Link Highlighting
    // ===================================
    const sections = document.querySelectorAll("section[id]");
    const navLinks = document.querySelectorAll(".header__nav-link, .header__mobile-nav-link");

    function highlightActiveSection() {
        const scrollPosition = window.scrollY;
        const headerHeight = 100; // Offset for header

        sections.forEach(function (section) {
            const sectionTop = section.offsetTop - headerHeight - 50;
            const sectionBottom = sectionTop + section.offsetHeight;
            const sectionId = section.getAttribute("id");

            if (scrollPosition >= sectionTop && scrollPosition < sectionBottom) {
                navLinks.forEach(function (link) {
                    link.classList.remove("is-active");
                    link.removeAttribute("aria-current");
                    if (link.getAttribute("href") === "#" + sectionId) {
                        link.classList.add("is-active");
                        link.setAttribute("aria-current", "true");
                    }
                });
            }
        });
    }

    // Throttle scroll events
    let scrollTimeout;
    window.addEventListener("scroll", function () {
        if (scrollTimeout) {
            window.cancelAnimationFrame(scrollTimeout);
        }
        scrollTimeout = window.requestAnimationFrame(highlightActiveSection);
    });

    // Run once on load
    highlightActiveSection();

    // ===================================
    // Reduced Motion Support
    // ===================================
    const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

    function handleReducedMotion() {
        if (prefersReducedMotion.matches) {
            // Disable smooth scrolling
            document.documentElement.style.scrollBehavior = "auto";
        } else {
            document.documentElement.style.scrollBehavior = "smooth";
        }
    }

    handleReducedMotion();
    prefersReducedMotion.addEventListener("change", handleReducedMotion);

    // ===================================
    // Keyboard Navigation Enhancement
    // ===================================
    document.addEventListener("keydown", function (e) {
        // Skip to main content with Tab from skip link
        const skipLink = document.querySelector(".skip-link");
        if (skipLink && document.activeElement === skipLink && e.key === "Enter") {
            e.preventDefault();
            const mainContent = document.querySelector("#main-content");
            if (mainContent) {
                mainContent.setAttribute("tabindex", "-1");
                mainContent.focus();
            }
        }
    });
})();
