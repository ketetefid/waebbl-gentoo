# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR=emake
PYTHON_COMPAT=( python2_7 )

inherit cmake-utils python-utils-r1 toolchain-funcs

MY_PV="$(ver_rs "1-3" '_')"
DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="https://graphics.pixar.com/opensubdiv/docs/intro.html"
SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

# Modfied Apache-2.0 license, where section 6 has been replaced.
# See for example CMakeLists.txt for details.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda doc opencl openmp ptex tbb"

RDEPEND="
	${PYTHON_DEPENDS}
	media-libs/glew:=
	media-libs/glfw:=
	cuda? ( dev-util/nvidia-cuda-toolkit:* )
	opencl? ( virtual/opencl )
	ptex? ( media-libs/ptex )
"
DEPEND="
	${RDEPEND}
	tbb? ( dev-cpp/tbb )
"
BDEPEND="
	doc? (
		dev-python/docutils
		app-doc/doxygen
	)
"

S="${WORKDIR}/OpenSubdiv-${MY_PV}"

PATCHES=(
	"${FILESDIR}/${PN}-3.3.0-fix-quotes.patch"
	"${FILESDIR}/${PN}-3.3.0-use-gnuinstalldirs.patch"
	"${FILESDIR}/${PN}-3.3.0-add-CUDA9-compatibility.patch"
	"${FILESDIR}/${P}-0001-documentation-CMakeLists.txt-force-python2.patch"
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	local mycmakeargs=(
		-DGLEW_LOCATION="${EPREFIX}/usr/$(get_libdir)"
		-DGLFW_LOCATION="${EPREFIX}/usr/$(get_libdir)"
		-DNO_CLEW=ON
		-DNO_CUDA=$(usex !cuda)
		-DNO_DOC=$(usex !doc)
		-DNO_EXAMPLES=ON # FIXME: add a USE flag to install them?
		-DNO_GLTESTS=ON # FIXME: test and allow this
		-DNO_OMP=$(usex !openmp)
		-DNO_OPENCL=$(usex !opencl)
		-DNO_PTEX=$(usex !ptex)
		-DNO_REGRESSION=ON # FIXME: They don't work with certain settings
		-DNO_TBB=$(usex !tbb)
		-DNO_TESTS=ON # FIXME: test and allow this
		-DNO_TUTORIALS=ON # FIXME: They install illegally. Need to find a better solution.
	)

	# fails with building cuda kernels when using multiple jobs
	export MAKEOPTS="-j1"
	cmake-utils_src_configure
}
