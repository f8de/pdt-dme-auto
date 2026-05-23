"""
Generate packaging/icon.ico for dme-auto.exe.
Design: dark blue rounded square, white clipboard, green checkmark.
Run once: python scripts/generate_icon.py
"""

from pathlib import Path
from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parent.parent / "packaging" / "icon.ico"
SIZES = [16, 32, 48, 256]

BLUE       = (26,  82, 148)   # background
WHITE      = (255, 255, 255)
GREEN      = (34,  197, 94)
DARK_LINE  = (20,  60, 110)


def draw_icon(size: int) -> Image.Image:
    img  = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d    = ImageDraw.Draw(img)
    pad  = max(1, size // 16)
    r    = max(2, size // 8)   # corner radius

    # ── background rounded rect ───────────────────────────────────────────────
    d.rounded_rectangle([pad, pad, size - pad - 1, size - pad - 1],
                        radius=r, fill=BLUE)

    if size <= 16:
        # 16px: white background, bold blue "D" + green dot — high contrast
        d.rounded_rectangle([pad, pad, size - pad - 1, size - pad - 1],
                            radius=r, fill=WHITE)
        # Bold blue border
        d.rounded_rectangle([pad, pad, size - pad - 1, size - pad - 1],
                            radius=r, outline=BLUE, width=max(1, size // 8))
        # Green dot bottom-right corner
        dot_r = max(2, size // 5)
        d.ellipse([size - pad - dot_r * 2 - 1, size - pad - dot_r * 2 - 1,
                   size - pad - 1, size - pad - 1], fill=GREEN)
        return img

    # ── clipboard body ────────────────────────────────────────────────────────
    cl  = round(size * 0.22)
    cr  = round(size * 0.78)
    ct  = round(size * 0.28)
    cb  = round(size * 0.82)
    cr_ = max(1, size // 16)
    d.rounded_rectangle([cl, ct, cr, cb], radius=cr_, fill=WHITE)

    # clip tab
    tw = round(size * 0.22)
    th = round(size * 0.10)
    tx = (size - tw) // 2
    ty = round(size * 0.20)
    d.rounded_rectangle([tx, ty, tx + tw, ty + th], radius=max(1, size // 20), fill=WHITE)
    # inner cutout on tab
    ti = max(1, size // 24)
    d.rounded_rectangle([tx + ti, ty + ti, tx + tw - ti, ty + th],
                        radius=max(1, size // 28), fill=BLUE)

    # lines on clipboard (only at 32px+)
    if size >= 32:
        lx1 = cl + round(size * 0.10)
        lx2 = cr - round(size * 0.10)
        lc  = (200, 215, 235)
        for frac in [0.48, 0.58, 0.68]:
            ly = round(size * frac)
            d.rectangle([lx1, ly, lx2, ly + max(1, size // 48)], fill=lc)

    # ── checkmark (green, lower-right quadrant) ───────────────────────────────
    # Draw over the clipboard corner to signal "verified / done"
    cr_cx = round(size * 0.72)
    cr_cy = round(size * 0.72)
    cr_r  = round(size * 0.18)

    # green circle badge
    d.ellipse([cr_cx - cr_r, cr_cy - cr_r, cr_cx + cr_r, cr_cy + cr_r], fill=GREEN)

    # white checkmark inside badge
    ck_w = max(1, round(cr_r * 0.22))
    # left arm: bottom-left to mid
    p1 = (cr_cx - round(cr_r * 0.45), cr_cy)
    p2 = (cr_cx - round(cr_r * 0.10), cr_cy + round(cr_r * 0.38))
    # right arm: mid to top-right
    p3 = (cr_cx + round(cr_r * 0.45), cr_cy - round(cr_r * 0.38))
    d.line([p1, p2, p3], fill=WHITE, width=ck_w)

    return img


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    # Draw each size individually then pack into ICO
    frames = [draw_icon(s) for s in SIZES]
    # Pillow ICO plugin: save largest frame, list all sizes explicitly
    frames[-1].save(
        OUT, format="ICO",
        sizes=[(s, s) for s in SIZES],
        append_images=frames[:-1],
    )
    # Verify
    check = Image.open(OUT)
    actual = check.info.get("sizes", set())
    print(f"Icon saved: {OUT}  ({OUT.stat().st_size // 1024} KB)  sizes={sorted(actual)}")


if __name__ == "__main__":
    main()
