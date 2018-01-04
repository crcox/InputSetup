#!/usr/bin/env python
import argparse
import os
import sys
import pandas
import pkg_resources
import yaml
from hyperband import pick_best_hyperparameters
from mako.template import Template
resource_package = 'pycon'

resource_path_stub = os.path.join('templates','stub.mako')
stub_template_string = pkg_resources.resource_string(resource_package, resource_path_stub)
stub_template = Template(stub_template_string)

