from setuptools import setup, Extension
import pkgconfig
import numpy as np

d = pkgconfig.parse('libavformat libswscale opencv4')

print("Numpy dir: ", np.get_include())

mv_extractor = Extension('mv_extractor',
       include_dirs = [
              '/home/ffmpeg_sources/ffmpeg',
              *d['include_dirs'],
              np.get_include()
       ],
       library_dirs = d['library_dirs'],
       libraries = d['libraries'],
       sources = [
              'src/py_video_cap.cpp',
              'src/video_cap.cpp',
              'src/time_cvt.cpp',
              'src/mat_to_ndarray.cpp'
       ],
       extra_compile_args = ['-std=c++11'],
       extra_link_args = ['-fPIC', '-Wl,-Bsymbolic'])

setup (name = 'mv_extractor',
       author='Lukas Bommes',
       author_email=' ',
       license='MIT',
       url='https://github.com/LukasBommes/mv-extractor',
       description = ('Reads video frames and MPEG-4/H.264 motion vectors.'),
       keywords=['motion vector', 'video capture', 'mpeg4', 'h.264', 'compressed domain'],
       ext_modules = [mv_extractor],
       packages = ['mv_extractor'],
       package_dir = {'mv_extractor': 'src'},
       python_requires='>=3.6, <3.12',
       setup_requires=['wheel>=0.33.6', 'numpy>=1.17.0,<1.18'],
       install_requires=['pkgconfig>=1.5.1,<1.6', 'numpy>=1.17.0,<1.18'])
