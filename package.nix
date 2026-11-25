{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  icoutils,
  python3,
  coreutils,
  lsb-release,
  procps,
  which,
  alsa-lib,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  gst_all_1,
  libdrm,
  libGL,
  libgbm,
  libjpeg8,
  libpulseaudio,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libXtst,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  libxkbcommon,
  libxkbfile,
  libxshmfence,
  libxcrypt-legacy,
  libSM,
  libICE,
  libaom,
  cups,
  nspr,
  nss,
  snappy,
  wayland,
  zlib,
}:

let
  version = "8.1.3";
  keyAccount = "1291";
  base = "https://dls.photoprintit.com/download/Data";

  # Files from ${base}/${keyAccount}-de_DE/hps/38-index-${version}.txt
  # marked for all platforms ("a") or 64-bit Linux ("l64").
  archives = [
    {
      path = "${keyAccount}-de_DE/hps/${version}/38-linuxexe64-${version}_3c0d279f47d7a90025d46b054c0d7095.7z";
      hash = "sha256-KSvw/oyQPqQKxEiG0lIusur8yjIScKloEu4B1RiaABU=";
    }
    {
      path = "generic-data/hps/${version}/38-linuxlib64-${version}_0d027258c7b3ed7424b66d2187f3b6ea.7z";
      hash = "sha256-s0JroatiTUbYdabo1kQZXdTbuHp55mfoOjzowYrBm0A=";
    }
    {
      path = "${keyAccount}-de_DE/hps/${version}/38-startscreen-${version}_5ee7f458604a4c7994ac91dda0c4c92d.7z";
      hash = "sha256-eRPCCZqGofVv1MTLMdBRmSc0tmghmQbPMNji3OHe0gs=";
    }
    {
      path = "${keyAccount}-de_DE/hps/${version}/38-resources-${version}_a337e3fd4c9c22256baad1ef3f00ec66.7z";
      hash = "sha256-KbvZ9tAJkeZ0BEKjsym80zJzoCPwZvUCPOwnfbTMjks=";
    }
    {
      path = "${keyAccount}-de_DE/hps/${version}/38-photofun-${version}_d010596e46a9f8aec1daec49339f9e91.7z";
      hash = "sha256-v5RrwzstDDlODumKHAvlpzofVETyBPjU1igKVOyPV0c=";
    }
    {
      path = "generic-data/hps/${version}/38-svgtemplates-${version}_c85486ca9a6c77de7432a34cca6c186c.7z";
      hash = "sha256-uG90n/2amrTuPsf3tw+VMqEqAg19C/hrMzxQJUR0llw=";
    }
    {
      path = "generic-data/hps/${version}/38-backgrounds-${version}_e7d190b4835e27e985994051f7baa2e5.7z";
      hash = "sha256-yP1x0646SBW/gcS4gV9/gmzeLtf2IoR30024SRr7TiI=";
    }
    {
      path = "generic-data/hps/${version}/38-decorations-${version}_737db809e6eb881a67a0127324bbf245.7z";
      hash = "sha256-ZT6Faot4WRTz3uGuVx5ssZfE177TXHGRdMxFdmXnAfM=";
    }
    {
      path = "generic-data/hps/${version}/38-svgcalendars-${version}_cb98ce220db85172ed0c16e9e22a36d7.7z";
      hash = "sha256-O4ZJr1Sol58F5Z0Q4XA27mnxjbXp90g+NYh722V/tLU=";
    }
  ];

  mimeType = "application/x-hps-${version}-mcf";
  iconName = "pixum-fotowelt";
in
stdenv.mkDerivation {
  pname = "pixum-fotowelt";
  inherit version;

  srcs = map (
    a:
    fetchurl {
      url = "${base}/${a.path}";
      inherit (a) hash;
    }
  ) archives;

  nativeBuildInputs = [
    _7zz
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    icoutils
    python3
  ];

  buildInputs = [
    alsa-lib
    dbus
    expat
    fontconfig
    freetype
    glib
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    libdrm
    libGL
    libgbm
    libjpeg8
    libpulseaudio
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXtst
    libxcb
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    libxkbcommon
    libxkbfile
    libxshmfence
    libxcrypt-legacy
    libSM
    libICE
    libaom
    cups
    nspr
    nss
    snappy
    stdenv.cc.cc.lib
    wayland
    zlib
  ];

  # Same as the vendor installer: every archive goes into one directory.
  unpackPhase = ''
    runHook preUnpack
    mkdir app
    for src in $srcs; do
      7zz x -y -bso0 -bsp0 -oapp "$src"
    done
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;
  # Stripping the vendor binaries breaks them (see the AUR package).
  dontStrip = true;

  # Only needed by optional Qt plugins whose libraries the vendor does not ship.
  autoPatchelfIgnoreMissingDeps = [
    "libQt6EglFSDeviceIntegration.so.6"
    "libQt6WebEngineQuick.so.6"
    "libQt6WebView.so.6"
    "libQt6WebViewQuick.so.6"
    "libQt6WlShellIntegration.so.6"
  ];

  installPhase = ''
    runHook preInstall

    appDir=$out/opt/pixum-fotowelt
    mkdir -p $out/opt $out/bin
    cp -r app $appDir
    cd $appDir

    # The installer creates libfoo.so and libfoo.so.N links for each libfoo.so.N.M.K.
    for f in *.so.*; do
      [ -L "$f" ] && continue
      base=''${f%%.so.*}.so
      ver=''${f#*.so.}
      ln -sf "$f" "$base"
      link=$base
      IFS=. read -ra parts <<< "$ver"
      for p in "''${parts[@]}"; do
        link=$link.$p
        [ "$link" != "$f" ] && ln -sf "$f" "$link"
      done
    done

    chmod 755 "Pixum Fotowelt" "Pixum Fotoschau" faceRecognition gpuprobe IconExtractor \
      regedit autoBookEventClassifier AutoBookService ffmpeg ffprobe CWQtWebEngineProcess

    # The built-in updater would try to write into the read-only store.
    rm -f updater.pl

    # libCWCore runs the hardcoded /bin/pidof to look for running AutoBookService
    # and hps processes. Without it the app stays on the splash screen forever,
    # which happens on NixOS.
    # Replace it with ././/pidof: same length, resolved against the working
    # directory the wrapper sets.
    python3 - <<'EOF'
    path = "libCWCore.so.0.1.0"
    old, new = ("/bin/pidof".encode("utf-16-le"), "././/pidof".encode("utf-16-le"))
    data = open(path, "rb").read()
    assert data.count(old) == 1, f"expected exactly one /bin/pidof in {path}"
    open(path, "wb").write(data.replace(old, new))
    EOF
    ln -s ${procps}/bin/pidof pidof

    # The app also calls which, lsb_release and chmod through PATH.
    makeWrapper "$appDir/Pixum Fotowelt" $out/bin/pixum-fotowelt \
      --chdir "$appDir" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          lsb-release
          which
        ]
      }

    # Icons from the vendor .ico
    icotool -x -o . Resources/keyaccount/32.ico
    for png in 32_*_*x*x*.png; do
      dim=$(echo "$png" | grep -oE '[0-9]+x[0-9]+' | head -1)
      install -Dm644 "$png" $out/share/icons/hicolor/$dim/apps/${iconName}.png
    done
    rm -f 32_*.png

    # File type for saved projects (.mcf/.mcfx)
    mkdir -p $out/share/mime/packages
    cat > $out/share/mime/packages/${iconName}.xml <<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="${mimeType}">
        <comment>Pixum Fotowelt</comment>
        <glob pattern="*.mcf"/>
        <glob pattern="*.mcfx"/>
        <magic><match value="createdWithHPSVersion" type="string" offset="0"/></magic>
        <icon name="${iconName}"/>
      </mime-type>
    </mime-info>
    EOF

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "pixum-fotowelt";
      desktopName = "Pixum Fotowelt";
      comment = "Create and order photo books and other photo products from Pixum";
      exec = "pixum-fotowelt %u";
      icon = iconName;
      categories = [
        "Graphics"
        "Photography"
      ];
      mimeTypes = [
        mimeType
        "x-scheme-handler/hps-${keyAccount}"
      ];
      startupNotify = true;
    })
  ];

  meta = {
    description = "Offline client for creating photo books and other photo products and ordering them from Pixum";
    homepage = "https://www.pixum.de/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "pixum-fotowelt";
  };
}
