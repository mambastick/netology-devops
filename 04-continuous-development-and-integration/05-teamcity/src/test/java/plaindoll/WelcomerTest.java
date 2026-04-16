package plaindoll;

import org.junit.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;

public class WelcomerTest {
    private final Welcomer welcomer = new Welcomer();

    @Test
    public void welcomerSaysWelcome() {
        assertThat(welcomer.sayWelcome(), containsString("Welcome"));
    }

    @Test
    public void welcomerSaysFarewell() {
        assertThat(welcomer.sayFarewell(), containsString("Farewell"));
    }

    @Test
    public void welcomerSaysHunterReply() {
        assertThat(welcomer.sayHunterReply(), containsString("hunter"));
    }
}

