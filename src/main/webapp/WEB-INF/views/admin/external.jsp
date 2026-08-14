<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - External Sources</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<% String activePage = "external"; %>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-globe"></i> External Sources</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <div class="note">
        <i class="icon icon-info"></i> This page will connect to live APIs for real-time data in a future update.
        Results below are sorted by distance from the hospital by default.
    </div>

    <!-- Search -->
    <div class="card">
        <div class="card-header"><h3><i class="icon icon-search"></i> Search for Blood Components or Medicines</h3></div>
        <div class="search-row">
            <select style="width:auto;">
                <option>Blood Bank</option>
                <option>Pharmacy</option>
            </select>
            <input type="text" placeholder="e.g. O+ Red Blood Cells, Paracetamol 500mg..." />
            <button class="search-btn">Search</button>
        </div>
    </div>

    <!-- Tabs -->
    <div class="tabs">
        <a href="#" class="tab-btn active" onclick="showTab('blood', this); return false;"><i class="icon icon-droplet"></i> Blood Banks</a>
        <a href="#" class="tab-btn" onclick="showTab('pharmacy', this); return false;"><i class="icon icon-pill"></i> Pharmacies</a>
    </div>

    <!-- Blood Banks -->
    <div id="blood-tab">

        <div class="sort-row">
            <span>Showing 5 blood banks near hospital</span>
            <select onchange="sortSources(this.value)">
                <option value="distance">Sort by Distance</option>
                <option value="price">Sort by Price</option>
                <option value="availability">Sort by Availability</option>
            </select>
        </div>

        <div class="source-card">
            <div class="source-info">
                <div class="source-name">City Blood Bank</div>
                <div class="source-address"><i class="icon icon-map-pin"></i> 12 MG Road, Bengaluru &mdash; 1.2 km away</div>
                <div class="source-tags">
                    <span class="badge green">O+ Available</span>
                    <span class="badge green">A+ Available</span>
                    <span class="badge red">AB- Not Available</span>
                </div>
                <a href="#" class="contact-btn"><i class="icon icon-phone"></i> 080-2345-6789</a>
            </div>
            <div class="source-meta">
                <div class="source-distance">1.2 km</div>
                <div class="source-distance-label">from hospital</div>
                <div class="source-price">&#8377;1,200 / unit</div>
                <div class="source-availability">Open 24/7</div>
            </div>
        </div>

        <div class="source-card">
            <div class="source-info">
                <div class="source-name">Red Cross Blood Centre</div>
                <div class="source-address"><i class="icon icon-map-pin"></i> 45 Brigade Road, Bengaluru &mdash; 2.8 km away</div>
                <div class="source-tags">
                    <span class="badge green">All Groups Available</span>
                    <span class="badge blue">Platelets Available</span>
                </div>
                <a href="#" class="contact-btn"><i class="icon icon-phone"></i> 080-9876-5432</a>
            </div>
            <div class="source-meta">
                <div class="source-distance">2.8 km</div>
                <div class="source-distance-label">from hospital</div>
                <div class="source-price">&#8377;1,050 / unit</div>
                <div class="source-availability">Open 8AM&ndash;10PM</div>
            </div>
        </div>

        <div class="source-card">
            <div class="source-info">
                <div class="source-name">Apollo Blood Bank</div>
                <div class="source-address"><i class="icon icon-map-pin"></i> Apollo Hospital, Bannerghatta Road &mdash; 4.1 km away</div>
                <div class="source-tags">
                    <span class="badge green">O+ Available</span>
                    <span class="badge green">B+ Available</span>
                    <span class="badge orange">A- Limited</span>
                </div>
                <a href="#" class="contact-btn"><i class="icon icon-phone"></i> 080-1122-3344</a>
            </div>
            <div class="source-meta">
                <div class="source-distance">4.1 km</div>
                <div class="source-distance-label">from hospital</div>
                <div class="source-price">&#8377;1,400 / unit</div>
                <div class="source-availability">Open 24/7</div>
            </div>
        </div>

        <div class="source-card">
            <div class="source-info">
                <div class="source-name">Manipal Blood Centre</div>
                <div class="source-address"><i class="icon icon-map-pin"></i> Old Airport Road, Bengaluru &mdash; 5.6 km away</div>
                <div class="source-tags">
                    <span class="badge green">FFP Available</span>
                    <span class="badge green">Platelets Available</span>
                    <span class="badge red">O- Not Available</span>
                </div>
                <a href="#" class="contact-btn"><i class="icon icon-phone"></i> 080-5566-7788</a>
            </div>
            <div class="source-meta">
                <div class="source-distance">5.6 km</div>
                <div class="source-distance-label">from hospital</div>
                <div class="source-price">&#8377;990 / unit</div>
                <div class="source-availability">Open 24/7</div>
            </div>
        </div>

    </div>

    <!-- Pharmacies (hidden by default) -->
    <div id="pharmacy-tab" style="display:none">

        <div class="sort-row">
            <span>Showing 4 pharmacies near hospital</span>
            <select>
                <option value="distance">Sort by Distance</option>
                <option value="price">Sort by Price</option>
                <option value="availability">Sort by Availability</option>
            </select>
        </div>

        <div class="source-card">
            <div class="source-info">
                <div class="source-name">MedPlus Pharmacy</div>
                <div class="source-address"><i class="icon icon-map-pin"></i> Ground Floor, Hospital Complex &mdash; 0.1 km away</div>
                <div class="source-tags">
                    <span class="badge green">In Stock</span>
                    <span class="badge blue">Home Delivery</span>
                </div>
                <a href="#" class="contact-btn"><i class="icon icon-phone"></i> 080-1111-2222</a>
            </div>
            <div class="source-meta">
                <div class="source-distance">0.1 km</div>
                <div class="source-distance-label">from hospital</div>
                <div class="source-price">Market Price</div>
                <div class="source-availability">Open 7AM&ndash;11PM</div>
            </div>
        </div>

        <div class="source-card">
            <div class="source-info">
                <div class="source-name">Apollo Pharmacy</div>
                <div class="source-address"><i class="icon icon-map-pin"></i> 15 Park Street, Bengaluru &mdash; 0.8 km away</div>
                <div class="source-tags">
                    <span class="badge green">In Stock</span>
                    <span class="badge green">Generics Available</span>
                    <span class="badge blue">Home Delivery</span>
                </div>
                <a href="#" class="contact-btn"><i class="icon icon-phone"></i> 080-3333-4444</a>
            </div>
            <div class="source-meta">
                <div class="source-distance">0.8 km</div>
                <div class="source-distance-label">from hospital</div>
                <div class="source-price">10% Discount</div>
                <div class="source-availability">Open 24/7</div>
            </div>
        </div>

        <div class="source-card">
            <div class="source-info">
                <div class="source-name">Netmeds Local Store</div>
                <div class="source-address"><i class="icon icon-map-pin"></i> 22 Commercial Street &mdash; 1.4 km away</div>
                <div class="source-tags">
                    <span class="badge orange">Limited Stock</span>
                    <span class="badge blue">Online Order</span>
                </div>
                <a href="#" class="contact-btn"><i class="icon icon-phone"></i> 080-5555-6666</a>
            </div>
            <div class="source-meta">
                <div class="source-distance">1.4 km</div>
                <div class="source-distance-label">from hospital</div>
                <div class="source-price">15% Cheaper</div>
                <div class="source-availability">Open 9AM&ndash;9PM</div>
            </div>
        </div>

        <div class="source-card">
            <div class="source-info">
                <div class="source-name">Wellness Forever</div>
                <div class="source-address"><i class="icon icon-map-pin"></i> 35 Residency Road &mdash; 2.1 km away</div>
                <div class="source-tags">
                    <span class="badge green">In Stock</span>
                    <span class="badge green">Surgical Supplies</span>
                </div>
                <a href="#" class="contact-btn"><i class="icon icon-phone"></i> 080-7777-8888</a>
            </div>
            <div class="source-meta">
                <div class="source-distance">2.1 km</div>
                <div class="source-distance-label">from hospital</div>
                <div class="source-price">Market Price</div>
                <div class="source-availability">Open 8AM&ndash;10PM</div>
            </div>
        </div>

    </div>

</div>

<script>
    function showTab(tab, btn) {
        document.getElementById('blood-tab').style.display = tab === 'blood' ? 'block' : 'none';
        document.getElementById('pharmacy-tab').style.display = tab === 'pharmacy' ? 'block' : 'none';
        document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
    }
    function sortSources(by) {
        console.log('Sort by:', by);
    }
</script>

</body>
</html>
