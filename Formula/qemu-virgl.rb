class QemuVirgl < Formula
  desc "Emulator for x86 and PowerPC"
  homepage "https://www.qemu.org/"
  url "https://github.com/qemu/qemu.git", using: :git, revision: "2fa4ad3f9000c385f71237984fdd1eefe2a91900"
  version "20210725.1"
  license "GPL-2.0-only"

  bottle do
    root_url "https://github.com/knazarov/homebrew-qemu-virgl/releases/download/qemu-virgl-20210725.1"
    sha256 catalina: "1595106e66d077939eaab4a36aadf6ff6371caa29a854a0e0c655506d92ecddc"
  end

  depends_on "libtool" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build

  depends_on "glib"
  depends_on "gnutls"
  depends_on "jpeg"
  depends_on "knazarov/qemu-virgl/libangle"
  depends_on "knazarov/qemu-virgl/libepoxy-angle"
  depends_on "knazarov/qemu-virgl/virglrenderer"
  depends_on "libpng"
  depends_on "libssh"
  depends_on "libusb"
  depends_on "lzo"
  depends_on "ncurses"
  depends_on "nettle"
  depends_on "pixman"
  depends_on "snappy"
  depends_on "spice-protocol"
  depends_on "vde"

  # 820KB floppy disk image file of FreeDOS 1.2, used to test QEMU
  resource "test-image" do
    url "https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.2/FD12FLOPPY.zip"
    sha256 "81237c7b42dc0ffc8b32a2f5734e3480a3f9a470c50c14a9c4576a2561a35807"
  end

  # waiting for upstreaming of https://github.com/akihikodaki/qemu/tree/macos
  patch :p1 do
    url "https://raw.githubusercontent.com/knazarov/homebrew-qemu-virgl/8f364ec918c177cb5e72602f263fe0061066eea0/Patches/qemu-v04.diff"
    sha256 "5301b861cf17486043d212a4385280e0aa6dada9453bbe66c2db47c6299155e7"
  end

  patch :p1 do
    url "https://raw.githubusercontent.com/knazarov/homebrew-qemu-virgl/18e6df670467c9d2cd2ec18375f4539cd6105028/Patches/qemu-libusb-v01.diff"
    sha256 "2da15abeb2a8f859e7f2fae359ff5ded72ffa49c8db6bf4d90115fd1f5e01f22"
  end

  def install
    ENV["LIBTOOL"] = "glibtool"

    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --disable-bsd-user
      --disable-guest-agent
      --enable-curses
      --enable-libssh
      --enable-vde
      --extra-cflags=-DNCURSES_WIDECHAR=1
      --extra-cflags=-I#{Formula["libangle"].opt_prefix}/include
      --extra-cflags=-I#{Formula["libepoxy-angle"].opt_prefix}/include
      --extra-cflags=-I#{Formula["virglrenderer"].opt_prefix}/include
      --extra-cflags=-I#{Formula["spice-protocol"].opt_prefix}/include/spice-1
      --extra-ldflags=-L#{Formula["libangle"].opt_prefix}/lib
      --extra-ldflags=-L#{Formula["libepoxy-angle"].opt_prefix}/lib
      --extra-ldflags=-L#{Formula["virglrenderer"].opt_prefix}/lib
      --extra-ldflags=-L#{Formula["spice-protocol"].opt_prefix}/lib
      --disable-sdl
      --disable-gtk
    ]
    # Sharing Samba directories in QEMU requires the samba.org smbd which is
    # incompatible with the macOS-provided version. This will lead to
    # silent runtime failures, so we set it to a Homebrew path in order to
    # obtain sensible runtime errors. This will also be compatible with
    # Samba installations from external taps.
    args << "--smbd=#{HOMEBREW_PREFIX}/sbin/samba-dot-org-smbd"

    on_macos do
      args << "--enable-cocoa"
    end

    system "./configure", *args
    system "make", "V=1", "install"
  end

  test do
    expected = "QEMU Project"
    assert_match expected, shell_output("#{bin}/qemu-system-aarch64 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-alpha --version")
    assert_match expected, shell_output("#{bin}/qemu-system-arm --version")
    assert_match expected, shell_output("#{bin}/qemu-system-cris --version")
    assert_match expected, shell_output("#{bin}/qemu-system-hppa --version")
    assert_match expected, shell_output("#{bin}/qemu-system-i386 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-m68k --version")
    assert_match expected, shell_output("#{bin}/qemu-system-microblaze --version")
    assert_match expected, shell_output("#{bin}/qemu-system-microblazeel --version")
    assert_match expected, shell_output("#{bin}/qemu-system-mips --version")
    assert_match expected, shell_output("#{bin}/qemu-system-mips64 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-mips64el --version")
    assert_match expected, shell_output("#{bin}/qemu-system-mipsel --version")
    assert_match expected, shell_output("#{bin}/qemu-system-nios2 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-or1k --version")
    assert_match expected, shell_output("#{bin}/qemu-system-ppc --version")
    assert_match expected, shell_output("#{bin}/qemu-system-ppc64 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-riscv32 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-riscv64 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-rx --version")
    assert_match expected, shell_output("#{bin}/qemu-system-s390x --version")
    assert_match expected, shell_output("#{bin}/qemu-system-sh4 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-sh4eb --version")
    assert_match expected, shell_output("#{bin}/qemu-system-sparc --version")
    assert_match expected, shell_output("#{bin}/qemu-system-sparc64 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-tricore --version")
    assert_match expected, shell_output("#{bin}/qemu-system-x86_64 --version")
    assert_match expected, shell_output("#{bin}/qemu-system-xtensa --version")
    assert_match expected, shell_output("#{bin}/qemu-system-xtensaeb --version")
    resource("test-image").stage testpath
    assert_match "file format: raw", shell_output("#{bin}/qemu-img info FLOPPY.img")
  end
end
