#!/usr/bin/env python

import setuptools
from setuptools import setup, find_packages
from setuptools.command.install import install

# copy-paste from «hyrule» install:
class install(install):
    def run(self):
        super().run()
        import py_compile
        import hy  
        for path in set(self.get_outputs()):
            if path.endswith(".hy"):
                py_compile.compile(
                    path,
                    invalidation_mode=py_compile.PycInvalidationMode.CHECKED_HASH,
                )

libs_required = [
    'hy >= 1',
    'pyparsing >= 3'
]

setup(
    name='wy',
    version='0.2.0.dev1',
    setup_requires=['wheel'] + libs_required,
    install_requires=libs_required,
    packages = setuptools.find_packages(exclude = ["private*", "tests*"]),
    package_data={'': ['*.hy']},
    entry_points={
        "console_scripts": [
            "wy2hy = wy.wy2hy:run_wy2hy_script"
        ]
    },
    author='Roman Averyanov',
    author_email='averrmn@gmail.com',
    description='wy2hy transpiler',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url='https://github.com/rmnavr/wy',
    classifiers=[
        'Programming Language :: Hy',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.9', 
)
