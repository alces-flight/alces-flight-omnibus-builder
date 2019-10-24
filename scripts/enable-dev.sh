#!/bin/bash
yum-config-manager --disable alces-flight
yum-config-manager --enable alces-flight-dev
yum-config-manager --disable openflight
yum-config-manager --enable openflight-dev
