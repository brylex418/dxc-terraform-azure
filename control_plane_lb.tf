resource "azurerm_public_ip" "control_plane_lb" {
  name                         = "${var.env_name}-control-plane-lb"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.pcf_resource_group.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_lb" "control_plane_lb" {
  name                = "control_plane"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.control_plane_lb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "web-backend" {
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.control_plane_lb.id}"
  name                = "Web"
}

resource "azurerm_lb_probe" "credhub_probe" {
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.control_plane_lb.id}"
  name                = "credhub_probe"
  port                = 8844
}

resource "azurerm_lb_probe" "https_probe" {
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.control_plane_lb.id}"
  name                = "https_probe"
  port                = 443
}

resource "azurerm_lb_probe" "http_probe" {
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.control_plane_lb.id}"
  name                = "http_probe"
  port                = 80
}

resource "azurerm_lb_probe" "uaa_probe" {
  resource_group_name = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.control_plane_lb.id}"
  name                = "uaa_probe"
  port                = 8443
}

resource "azurerm_lb_rule" "CREDHUB_RULE" {
  resource_group_name            = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.control_plane_lb.id}"
  name                           = "CREDHUB"
  protocol                       = "Tcp"
  frontend_port                  = 8844
  backend_port                   = 8844
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.web-backend.id}"
  probe_id                       = "${azurerm_lb_probe.credhub_probe.id}"
}

resource "azurerm_lb_rule" "HTTPS_RULE" {
  resource_group_name            = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.control_plane_lb.id}"
  name                           = "HTTPS"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.web-backend.id}"
  probe_id                       = "${azurerm_lb_probe.https_probe.id}"
}

resource "azurerm_lb_rule" "HTTP_RULE" {
  resource_group_name            = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.control_plane_lb.id}"
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.web-backend.id}"
  probe_id                       = "${azurerm_lb_probe.http_probe.id}"
}

resource "azurerm_lb_rule" "UAA_RULE" {
  resource_group_name            = "${azurerm_resource_group.pcf_resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.control_plane_lb.id}"
  name                           = "UAA"
  protocol                       = "Tcp"
  frontend_port                  = 8443
  backend_port                   = 8443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.web-backend.id}"
  probe_id                       = "${azurerm_lb_probe.uaa_probe.id}"
}
