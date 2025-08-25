import React, { useEffect } from 'react';
import './App.css';

function App() {
    useEffect(() => {
        // Ensure the widget script is loaded
        const script = document.createElement('script');
        script.src = 'https://unpkg.com/@elevenlabs/convai-widget-embed';
        script.async = true;
        script.type = 'text/javascript';

        if (!document.querySelector('script[src*="convai-widget-embed"]')) {
            document.head.appendChild(script);
        }
    }, []);

    return (
        <div className="App">
            {/* Header */}
            <header className="header">
                <div className="container">
                    <div className="header-content">
                        <div className="logo">
                            <h1>Konditorei</h1>
                        </div>
                        <nav className="nav">
                            <ul>
                                <li><a href="#menu">Menu</a></li>
                                <li><a href="#about">About Us</a></li>
                                <li><a href="#contact">Contact</a></li>
                            </ul>
                        </nav>
                        <div className="header-actions">
                            <span className="open-status">Open Now</span>
                            <span className="hours">6:30 AM - 5:00 PM</span>
                        </div>
                    </div>
                </div>
            </header>

            {/* Hero Section */}
            <section
                className="hero"
                style={{
                    background: `linear-gradient(rgba(139, 69, 19, 0.8), rgba(210, 105, 30, 0.8)), url('/images/hero-bg.jpg')`,
                    backgroundSize: 'cover',
                    backgroundPosition: 'center',
                    backgroundAttachment: 'fixed'
                }}
            >
                <div className="container">
                    <div className="hero-content">
                        <h1>Konditorei Cafe - Sandwich & Bagels in Portola Valley, CA</h1>
                        <p>Your neighborhood spot for delicious, handcrafted sandwiches and fresh-baked bagels</p>
                        <div className="hero-buttons">
                            <button className="btn btn-primary">Order Now</button>
                            <button className="btn btn-secondary">Call Us</button>
                        </div>
                    </div>
                </div>
            </section>

            {/* Menu Favorites */}
            <section className="menu-favorites" id="menu">
                <div className="container">
                    <h2>Browse our Favorites</h2>
                    <div className="menu-grid">
                        <div className="menu-item">
                            <div className="menu-item-image">
                                <img src="/images/latte.jpg" alt="Latte" />
                            </div>
                            <h3>Latte</h3>
                            <button className="btn btn-outline">Order Now</button>
                        </div>
                        <div className="menu-item">
                            <div className="menu-item-image">
                                <img src="/images/matcha-latte.jpg" alt="Matcha Latte" />
                            </div>
                            <h3>Matcha Latte</h3>
                            <button className="btn btn-outline">Order Now</button>
                        </div>
                        <div className="menu-item">
                            <div className="menu-item-image">
                                <img src="/images/cold-brew.jpg" alt="Cold Brew" />
                            </div>
                            <h3>Cold Brew</h3>
                            <button className="btn btn-outline">Order Now</button>
                        </div>
                        <div className="menu-item">
                            <div className="menu-item-image">
                                <img src="/images/avocado-bagel.jpg" alt="Avocado Bagel" />
                            </div>
                            <h3>Avocado Bagel</h3>
                            <p>Sliced avocado with salt & pepper, on a toasted bagel of your choice</p>
                            <button className="btn btn-outline">Order Now</button>
                        </div>
                        <div className="menu-item">
                            <div className="menu-item-image">
                                <img src="/images/lox-schmear.jpg" alt="Lox & Schmear" />
                            </div>
                            <h3>Lox & Schmear</h3>
                            <p>Smoked salmon, red onion, and plain cream cheese. On a toasted bagel.</p>
                            <button className="btn btn-outline">Order Now</button>
                        </div>
                        <div className="menu-item">
                            <div className="menu-item-image">
                                <img src="/images/turkey-avocado.jpg" alt="Turkey Avocado" />
                            </div>
                            <h3>Turkey Avocado</h3>
                            <p>Turkey, avocado, onion, tomato, cucumber, lettuce, mayo, and mustard. On a toasted bagel.</p>
                            <button className="btn btn-outline">Order Now</button>
                        </div>
                    </div>
                </div>
            </section>

            {/* About Section */}
            <section className="about" id="about">
                <div className="container">
                    <div className="about-content">
                        <h2>Best Sandwich and Bagel Shop in Portola Valley, CA</h2>
                        <p>
                            Looking for the perfect breakfast or lunch in Portola Valley? Look no further than Konditorei Cafe!
                            We're your neighborhood spot for delicious, handcrafted sandwiches and fresh-baked bagels. Made with
                            locally sourced ingredients whenever possible, our menu offers something for everyone, from classic
                            favorites to unique flavor combinations.
                        </p>
                        <p>
                            Start your day right with a bagel loaded with your favorite toppings, or savor a satisfying sandwich
                            piled high with fresh meats, cheeses, and crisp veggies. We take pride in using quality ingredients
                            and crafting every bite to perfection.
                        </p>
                        <button className="btn btn-primary">Learn More About Us</button>
                    </div>
                </div>
            </section>

            {/* Customer Reviews */}
            <section className="reviews">
                <div className="container">
                    <h2>What our Customers Are Saying</h2>
                    <div className="reviews-grid">
                        <div className="review-card">
                            <div className="review-header">
                                <h4>Suzanne Frey</h4>
                                <span className="review-date">05/02/2025</span>
                            </div>
                            <div className="stars">⭐⭐⭐⭐⭐</div>
                            <p>"Fast service, great bagels. I don't like the coffee beans they use (more on the fruity/bitter side of things), but this place serves a valuable role in Portola Valley and provides a quick/easy AM fix."</p>
                        </div>
                        <div className="review-card">
                            <div className="review-header">
                                <h4>M Ferrick</h4>
                                <span className="review-date">04/13/2025</span>
                            </div>
                            <div className="stars">⭐⭐⭐⭐⭐</div>
                            <p>"It's been awhile since I had an excellent latte. They had it dialed in. I ordered a Baja Mushroom breakfast sandwich in a croissant 🥐it was so delicious 😋. Hope to return again."</p>
                        </div>
                        <div className="review-card">
                            <div className="review-header">
                                <h4>Brian Archbold</h4>
                                <span className="review-date">04/29/2024</span>
                            </div>
                            <div className="stars">⭐⭐⭐⭐⭐</div>
                            <p>"This coffee shop is in a great location, the people running it and serving customers are the best, coffee and food is great."</p>
                        </div>
                    </div>
                </div>
            </section>

            {/* Contact Section */}
            <section className="contact" id="contact">
                <div className="container">
                    <div className="contact-content">
                        <h2>Locally Owned and Operated</h2>
                        <div className="contact-info">
                            <div className="contact-item">
                                <h3>📍 Address</h3>
                                <p>3130 Alpine Rd<br />Portola Valley, CA 94028</p>
                            </div>
                            <div className="contact-item">
                                <h3>📞 Phone</h3>
                                <p>(650) 854-8616</p>
                            </div>
                            <div className="contact-item">
                                <h3>🕒 Hours</h3>
                                <div className="hours-list">
                                    <div><strong>Monday:</strong> 6:30 AM - 5:00 PM</div>
                                    <div><strong>Tuesday:</strong> 6:30 AM - 1:00 PM</div>
                                    <div><strong>Wednesday:</strong> 6:30 AM - 5:00 PM</div>
                                    <div><strong>Thursday:</strong> 6:30 AM - 5:00 PM</div>
                                    <div><strong>Friday:</strong> 6:30 AM - 5:00 PM</div>
                                    <div><strong>Saturday:</strong> 7:00 AM - 2:30 PM</div>
                                    <div><strong>Sunday:</strong> 7:00 AM - 2:30 PM</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>



            {/* Footer */}
            <footer className="footer">
                <div className="container">
                    <div className="footer-content">
                        <div className="footer-section">
                            <h3>Konditorei</h3>
                            <ul>
                                <li><a href="#menu">Menu</a></li>
                                <li><a href="#about">About Us</a></li>
                                <li><a href="#contact">Contact</a></li>
                            </ul>
                        </div>
                        <div className="footer-section">
                            <p>&copy; 2025 Konditorei All Rights Reserved.</p>
                            <p>Privacy Policy | Terms and Conditions | Accessibility</p>
                        </div>
                    </div>
                </div>
            </footer>
        </div>
    );
}

export default App;
