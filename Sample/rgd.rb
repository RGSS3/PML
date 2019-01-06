x = Bitmap.new(32, 32)
x.fill_rect(x.rect, Color.new(255, 0, 0))
x.save_png("a.png")
system("start a.png")
rgss_stop