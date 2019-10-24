#!/bin/bash
yum-config-manager --disable alces-flight-dev
yum-config-manager --enable alces-flight
yum-config-manager --disable openflight-dev
yum-config-manager --enable openflight
