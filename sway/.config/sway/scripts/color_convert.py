import sys

def rgb_to_hsv(rgb):
    [r, g, b] = rgb
    M = max(rgb)
    m = min(rgb)
    C = M - m

    hue = (
        0 if C == 0 else
        60.0 * ((g - b) / C % 6) if M == r else
        60.0 * ((b - r) / C + 2) if M == g else
        60.0 * ((r - g) / C + 4))

    saturation = 0 if M == 0 else C / M

    value = M

    return [hue, saturation, value]

def rgb_to_hsl(rgb):
    [r, g, b] = rgb
    M = max(rgb)
    m = min(rgb)
    C = M - m
    L = (M + m) / 2

    hue = (
        0 if C == 0 else
        60.0 * ((g - b) / C % 6) if M == r else
        60.0 * ((b - r) / C + 2) if M == g else
        60.0 * ((r - g) / C + 4))

    saturation = (
        0 if L == 0 else
        0 if L == 1 else
        (M - L) / min(L, 1 - L))

    lightness = L

    return [hue, saturation, lightness]

if __name__ == "__main__":
    pixel = sys.stdin.read()
    pixel = pixel[:6]

    srgb = [int(s, 16) / 255.0 for s in [pixel[0:2], pixel[2:4], pixel[4:6]]]

    # source https://www.khronos.org/registry/DataFormat/specs/1.3/dataformat.1.3.html#TRANSFER_SRGB
    rgb = [s / 12.92 if s <= 0.04045 else ((s + 0.055) / 1.055) ** 2.4 for s in srgb]

    hsv = rgb_to_hsv(srgb)
    hsl = rgb_to_hsl(srgb)

    print("{}".format(pixel))
    print("({:f}, {:f}, {:f})".format(*srgb))
    print("({:f}, {:f}, {:f})".format(*rgb))
    print("({:f}, {:f}, {:f})".format(*hsv))
    print("({:f}, {:f}, {:f})".format(*hsl))
