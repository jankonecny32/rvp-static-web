// Inline gallery for service sections (index2.html)
// Shows thumbnail grid next to each service category with lightbox support.

document.addEventListener("DOMContentLoaded", function () {
    if (typeof galleryManifest === "undefined") return;

    var MAX_VISIBLE = 5; // show up to 5 thumbs, then a "+N" tile

    document.querySelectorAll(".service-gallery-grid").forEach(function (container) {
        var category = container.getAttribute("data-category");
        var images = galleryManifest[category];
        if (!images || images.length === 0) return;

        var lightboxGroup = "gallery-" + category;
        var visibleCount = Math.min(images.length, MAX_VISIBLE);
        var remaining = images.length - visibleCount;

        // Render visible thumbnails
        for (var i = 0; i < visibleCount; i++) {
            var thumbPath = "img/rvp/" + category + "/thumbs/" + images[i];
            var fullPath = "img/rvp/" + category + "/" + images[i];

            var thumbDiv = document.createElement("div");
            thumbDiv.className = "gallery-thumb";
            thumbDiv.innerHTML =
                '<a href="' + fullPath + '" data-lightbox="' + lightboxGroup + '">' +
                    '<img src="' + thumbPath + '" loading="lazy" alt="">' +
                '</a>';
            container.appendChild(thumbDiv);
        }

        // "+N more" tile or just the remaining hidden lightbox links
        if (remaining > 0) {
            // The "+more" tile triggers the lightbox for the next image
            var moreDiv = document.createElement("div");
            moreDiv.className = "gallery-more";
            var nextFullPath = "img/rvp/" + category + "/" + images[visibleCount];
            moreDiv.innerHTML =
                '<a href="' + nextFullPath + '" data-lightbox="' + lightboxGroup + '" style="text-decoration:none;">' +
                    '<span class="text-white fw-bold fs-4">+' + remaining + '</span>' +
                '</a>';
            container.appendChild(moreDiv);

            // Add hidden lightbox links for the rest
            for (var j = visibleCount + 1; j < images.length; j++) {
                var hiddenLink = document.createElement("a");
                hiddenLink.href = "img/rvp/" + category + "/" + images[j];
                hiddenLink.setAttribute("data-lightbox", lightboxGroup);
                hiddenLink.style.display = "none";
                container.appendChild(hiddenLink);
            }
        }
    });
});
