document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
	anchor.addEventListener("click", function (e) {
		e.preventDefault();
		const target = document.querySelector(this.getAttribute("href"));
		if (target) {
			target.scrollIntoView({
				behavior: "smooth",
				block: "start",
			});
		}
	});
});

const sections = document.querySelectorAll(".section");
const navLinks = document.querySelectorAll(".nav-links a");

window.addEventListener("scroll", () => {
	let current = "";

	sections.forEach((section) => {
		const sectionTop = section.offsetTop;
		const sectionHeight = section.clientHeight;
		if (window.pageYOffset >= sectionTop - 200) {
			current = section.getAttribute("id");
		}
	});

	navLinks.forEach((link) => {
		link.classList.remove("active");
		if (link.getAttribute("href").slice(1) === current) {
			link.classList.add("active");
		}
	});
});

const observerOptions = {
	threshold: 0.1,
	rootMargin: "0px 0px -100px 0px",
};

const observer = new IntersectionObserver((entries) => {
	entries.forEach((entry) => {
		if (entry.isIntersecting) {
			entry.target.style.opacity = "1";
			entry.target.style.transform = "translateY(0)";
		}
	});
}, observerOptions);

document
	.querySelectorAll(".tech-item, .skill-card, .project-card")
	.forEach((el) => {
		el.style.opacity = "0";
		el.style.transform = "translateY(30px)";
		el.style.transition = "opacity 0.6s ease, transform 0.6s ease";
		observer.observe(el);
	});

window.addEventListener("scroll", () => {
	const hero = document.querySelector(".hero");
	if (hero) {
		const scrolled = window.pageYOffset;
		hero.style.transform = `translateY(${scrolled * 0.5}px)`;
	}
});

function updateStatus() {
	const statusElements = document.querySelectorAll(".status.active");
	statusElements.forEach((status) => {
		status.style.animation = "pulse 2s infinite";
	});
}

const style = document.createElement("style");
style.textContent = `
    @keyframes pulse {
        0%, 100% {
            opacity: 1;
        }
        50% {
            opacity: 0.7;
        }
    }
`;
document.head.appendChild(style);

updateStatus();

const ctaButton = document.querySelector(".cta-button");
if (ctaButton) {
	ctaButton.addEventListener("mouseenter", function () {
		this.style.transform = "translateY(-3px) scale(1.05)";
	});

	ctaButton.addEventListener("mouseleave", function () {
		this.style.transform = "translateY(0) scale(1)";
	});
}

console.log(
	"%c Inception Project",
	"font-size: 20px; font-weight: bold; color: #2563eb;",
);
console.log("%cBuilt with Docker, Python", "font-size: 14px; color: #10b981;");
console.log("%cServices running:", "font-size: 12px; font-weight: bold;");
console.log("  WordPress + PHP-FPM");
console.log("  MariaDB");
console.log("  NGINX");
console.log("  Redis Cache");
console.log("  FTP Server");
console.log("  Adminer");
console.log("  Static Site (Python)");

window.addEventListener("load", () => {
	document.body.style.opacity = "0";
	document.body.style.transition = "opacity 0.5s ease";
	setTimeout(() => {
		document.body.style.opacity = "1";
	}, 100);
});

document.addEventListener("keydown", (e) => {
	if (e.key === "ArrowDown") {
		window.scrollBy({ top: 100, behavior: "smooth" });
	} else if (e.key === "ArrowUp") {
		window.scrollBy({ top: -100, behavior: "smooth" });
	}
});
