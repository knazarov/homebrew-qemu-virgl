class LibepoxyAngle < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"
  url "git@github.com:anholt/libepoxy.git", using: :git, revision: "de08cf3479ca06ff921c584eeee6280e5a135f99"
  version "20210315.1"
  license "MIT"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.9" => :build
  depends_on "knazarov/qemu-virgl/libangle"

  # waiting for upstreaming of https://github.com/akihikodaki/libepoxy/tree/macos
  patch :p1 do
    url "https://raw.githubusercontent.com/knazarov/homebrew-qemu-virgl/338af8ba4873c62e674e3d477f9213c301bb7f14/Patches/libepoxy-v01.diff"
    sha256 "962a81b1b51a8f86739518487a441ef16863aa4ab02fde14c60b67d29d2b970b"
  end

  def install
    mkdir "build" do
      system "meson", *std_meson_args, "-Dc_args=-I#{Formula["libangle"].opt_prefix}/include",
             "-Dc_link_args=-L#{Formula["libangle"].opt_prefix}/lib", "-Degl=yes", "-Dx11=false", ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS

      #include <epoxy/gl.h>
      #include <OpenGL/CGLContext.h>
      #include <OpenGL/CGLTypes.h>
      #include <OpenGL/OpenGL.h>
      int main()
      {
          CGLPixelFormatAttribute attribs[] = {0};
          CGLPixelFormatObj pix;
          int npix;
          CGLContextObj ctx;

          CGLChoosePixelFormat( attribs, &pix, &npix );
          CGLCreateContext(pix, (void*)0, &ctx);

          glClear(GL_COLOR_BUFFER_BIT);
          CGLReleasePixelFormat(pix);
          CGLReleaseContext(pix);
          return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lepoxy", "-framework", "OpenGL", "-o", "test"
    system "ls", "-lh", "test"
    system "file", "test"
    system "./test"
  end
end
